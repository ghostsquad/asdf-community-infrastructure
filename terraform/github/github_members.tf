######################
# GitHub Memberships #
######################

locals {
  github_memberships = {
    admins = [
      "smorimoto",
      "vic",
    ]

    members = [
      "jeffryang24",
      "looztra",
      "marciogm",
      "michaelstephens",
      "missingcharacter",
      "Naturalclar",
      "nverno",
      "nzws",
      "odarriba",
      "sasurau4",
      "schutm",
      "superbrothers",
    ]
  }
}

resource "github_membership" "memberships" {
  for_each = { for i in flatten(
    [for role, usernames in local.github_memberships :
      [for username in usernames : role == "admins" ? {
        username = username,
        role     = "admin",
        } : {
        username = username,
        role     = "member",
      }]
    ]) : "${i.role}_${i.username}" => i
  }

  username = each.value.username
  role     = each.value.role
}

########################
# GitHub Collaborators #
########################

locals {
  github_repository_collaborators = {
    asdf-crystal = [
      {
        username   = "mgxm",
        permission = "push",
      }
    ]

    asdf-gleam = [
      {
        username   = "lpil",
        permission = "push",
      }
    ]

    asdf-ubuntu = [
      {
        username   = "rodfersou",
        permission = "push",
      }
    ]
  }
}

resource "github_repository_collaborator" "repository_collaborator" {
  for_each = { for i in flatten(
    [for repository, collaborators in local.github_repository_collaborators :
      [for collaborator in collaborators : {
        repository = repository,
        username   = collaborator.username,
        permission = collaborator.permission,
      }]
    ]) : "${i.repository}_${i.username}" => i
  }

  repository = each.value.repository
  username   = each.value.username
  permission = each.value.permission
}

################
# GitHub Teams #
################

locals {
  github_teams = {
    plugin-committers = {
      description = "The people with push access"
      maintainers = [
        "smorimoto",
        "vic",
      ]
      members = [
        "jeffryang24",
        "looztra",
        "marciogm",
        "michaelstephens",
        "missingcharacter",
        "Naturalclar",
        "nverno",
        "nzws",
        "odarriba",
        "sasurau4",
        "schutm",
        "superbrothers",
      ]
    }

    asdf-ops = {
      description = "Infrastructure Operators"
      maintainers = [
        "smorimoto",
        "vic",
      ]
    }
  }
}

resource "github_team" "teams" {
  for_each = local.github_teams

  name        = each.key
  description = each.value.description
  privacy     = "closed"
}

resource "github_team_membership" "team_membership" {
  for_each = { for i in flatten(
    [for team_name, team in local.github_teams : [
      [for username in lookup(team, "maintainers", []) : {
        team_name = team_name,
        username  = username,
        role      = "maintainer",
      }],
      [for username in lookup(team, "members", []) : {
        team_name = team_name,
        username  = username,
        role      = "member",
      }],
    ]]) : "${i.team_name}_${i.username}" => i
  }

  team_id  = github_team.teams[each.value.team_name].id
  role     = each.value.role
  username = each.value.username
}