variable "roles" {
  description = "Roles"
  type = set(string)
  default = [ "jellyfin-admin", "jellyfin-user" ]
}

variable "libraries" {
  description = "Libraries"
  type = map(object({
    group        = string
    display_name = string
    host_path    = string
  }))
  default = {
    # video folders
    "animated" : {
      group        = "video"
      display_name = "Animated"
    }
    "anime" : {
      group        = "video"
      display_name = "Anime"
    }
    "concerts" : {
      group        = "video"
      display_name = "Concerts"
    }
    "movies" : {
      group        = "video"
      display_name = "Movies"
    }
    "e-movies" : {
      group        = "video"
      display_name = "E-movies"
    }
    "r-movies" : {
      group        = "video"
      display_name = "Russian movies"
    }
    "series" : {
      group        = "video"
      display_name = "TV series"
    }
    "vacation" : {
      group        = "video"
      display_name = "Vacation photos"
    }
    # pictures folder
    "igor" : {
      group        = "photo"
      display_name = "Igor's photos"
    }
    "mariia" : {
      group        = "photo"
      display_name = "Mariia's photos"
    }
    "yuliia" : {
      group        = "photo"
      display_name = "Yuliia's photos"
    }
    "vacation" : {
      group        = "photo"
      display_name = "Vacation photos"
    }
    # music folder
    "music" : {
      group        = "music"
      display_name = "Music"
    }
    # yuliia folder
    "yuliia-похудение" : {
      group        = "yuliia"
      display_name = "Yuliia похудение"
    }
    "yuliia-разное" : {
      group        = "yuliia"
      display_name = "Yuliia разное"
    }
  }
}