variable "admin_username" {
  description = "Admin username for Jellyfin initial setup"
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "Admin password for Jellyfin initial setup"
  type        = string
  sensitive   = true
}

variable "plugin_repositories" {
  description = "Repositories to set up and enable"
  nullable    = false
  type = list(object({
    Name    = string
    Url     = string
    Enabled = bool
  }))
  default = [
    {
      Name    = "Jellyfin Stable"
      Url     = "https://repo.jellyfin.org/files/plugin/manifest.json"
      Enabled = true
    },
    {
      Name    = "9p4 SSO"
      Url     = "https://raw.githubusercontent.com/9p4/jellyfin-plugin-sso/manifest-release/manifest.json"
      Enabled = true
    }
  ]
}

variable "plugins" {
  description = "Plugins to install"
  nullable    = false
  type = map(object({
    name          = string
    assembly_guid = string
    repository    = string
  }))
  default = {
    "sso" = {
      name          = "SSO Authentication"
      assembly_guid = "505ce9d1-d916-42fa-86ca-673ef241d7df"
      repository    = "https://raw.githubusercontent.com/9p4/jellyfin-plugin-sso/manifest-release/manifest.json"
    }
    "dlna" = {
      name          = "DLNA"
      assembly_guid = "33eba9cd-7da1-4720-967f-dd7dae7b74a1"
      repository    = "https://repo.jellyfin.org/files/plugin/manifest.json"
    }
  }
}

variable "library_options_templates" {
  description = "Library options templates with explicit values for all relevant properties"

  type = any

  default = {
    # =============================================================================
    # Movies with full TMDB metadata and subtitles
    # =============================================================================
    movies_metadata = {
      # Core settings
      Enabled                                 = true
      EnablePhotos                            = true
      EnableRealtimeMonitor                   = true
      
      # Scanning and extraction
      EnableLUFSScan                          = false
      EnableChapterImageExtraction            = true
      ExtractChapterImagesDuringLibraryScan   = true
      EnableTrickplayImageExtraction          = true
      ExtractTrickplayImagesDuringLibraryScan = true
      
      # Metadata
      SaveLocalMetadata                       = false
      EnableInternetProviders                 = true
      EnableAutomaticSeriesGrouping           = false
      EnableEmbeddedTitles                    = true
      EnableEmbeddedExtrasTitles              = true
      EnableEmbeddedEpisodeInfos              = false
      AutomaticRefreshIntervalDays            = 30
      
      # Subtitles
      SkipSubtitlesIfEmbeddedSubtitlesPresent = true
      SkipSubtitlesIfAudioTrackMatches        = true
      SubtitleDownloadLanguages               = ["ger", "eng", "rus"]
      RequirePerfectSubtitleMatch             = true
      SaveSubtitlesWithMedia                  = true
      AllowEmbeddedSubtitles                  = "AllowAll"
      
      # Other
      SaveLyricsWithMedia                     = false
      SaveTrickplayWithMedia                  = false
      PreferNonstandardArtistsTag             = false
      AutomaticallyAddToCollection            = true
      
      TypeOptions = [{
        Type                 = "Movie"
        MetadataFetchers     = ["TheMovieDb"]
        MetadataFetcherOrder = ["TheMovieDb"]
        ImageFetchers        = ["TheMovieDb"]
        ImageFetcherOrder    = ["TheMovieDb"]
      }]
    }

    # =============================================================================
    # TV Shows with full TMDB metadata
    # =============================================================================
    tvshows_metadata = {
      # Core settings
      Enabled                                 = true
      EnablePhotos                            = true
      EnableRealtimeMonitor                   = true
      
      # Scanning and extraction
      EnableLUFSScan                          = false
      EnableChapterImageExtraction            = true
      ExtractChapterImagesDuringLibraryScan   = true
      EnableTrickplayImageExtraction          = true
      ExtractTrickplayImagesDuringLibraryScan = true
      
      # Metadata
      SaveLocalMetadata                       = false
      EnableInternetProviders                 = true
      EnableAutomaticSeriesGrouping           = true
      EnableEmbeddedTitles                    = true
      EnableEmbeddedExtrasTitles              = true
      EnableEmbeddedEpisodeInfos              = true
      AutomaticRefreshIntervalDays            = 7
      
      # Subtitles
      SkipSubtitlesIfEmbeddedSubtitlesPresent = true
      SkipSubtitlesIfAudioTrackMatches        = true
      SubtitleDownloadLanguages               = ["ger", "eng", "rus"]
      RequirePerfectSubtitleMatch             = true
      SaveSubtitlesWithMedia                  = true
      AllowEmbeddedSubtitles                  = "AllowAll"
      
      # Other
      SaveLyricsWithMedia                     = false
      SaveTrickplayWithMedia                  = false
      PreferNonstandardArtistsTag             = false
      AutomaticallyAddToCollection            = true
      
      TypeOptions = [
        {
          Type                 = "Series"
          MetadataFetchers     = ["TheMovieDb"]
          MetadataFetcherOrder = ["TheMovieDb"]
          ImageFetchers        = ["TheMovieDb"]
          ImageFetcherOrder    = ["TheMovieDb"]
        },
        {
          Type                 = "Season"
          MetadataFetchers     = ["TheMovieDb"]
          MetadataFetcherOrder = ["TheMovieDb"]
          ImageFetchers        = ["TheMovieDb"]
          ImageFetcherOrder    = ["TheMovieDb"]
        },
        {
          Type                 = "Episode"
          MetadataFetchers     = ["TheMovieDb"]
          MetadataFetcherOrder = ["TheMovieDb"]
          ImageFetchers        = ["TheMovieDb", "Embedded Image Extractor", "Screen Grabber"]
          ImageFetcherOrder    = ["TheMovieDb", "Embedded Image Extractor", "Screen Grabber"]
        }
      ]
    }

    # =============================================================================
    # Home videos - no external metadata, local extraction only
    # =============================================================================
    homevideos = {
      # Core settings
      Enabled                                 = true
      EnablePhotos                            = true
      EnableRealtimeMonitor                   = true
      
      # Scanning and extraction (keep local extraction)
      EnableLUFSScan                          = false
      EnableChapterImageExtraction            = true
      ExtractChapterImagesDuringLibraryScan   = true
      EnableTrickplayImageExtraction          = true
      ExtractTrickplayImagesDuringLibraryScan = true
      
      # Metadata (disable internet)
      SaveLocalMetadata                       = false
      EnableInternetProviders                 = false
      EnableAutomaticSeriesGrouping           = false
      EnableEmbeddedTitles                    = true
      EnableEmbeddedExtrasTitles              = true
      EnableEmbeddedEpisodeInfos              = false
      AutomaticRefreshIntervalDays            = 0
      
      # Subtitles (minimal)
      SkipSubtitlesIfEmbeddedSubtitlesPresent = true
      SkipSubtitlesIfAudioTrackMatches        = true
      SubtitleDownloadLanguages               = []
      RequirePerfectSubtitleMatch             = true
      SaveSubtitlesWithMedia                  = false
      AllowEmbeddedSubtitles                  = "AllowAll"
      
      # Other
      SaveLyricsWithMedia                     = false
      SaveTrickplayWithMedia                  = false
      PreferNonstandardArtistsTag             = false
      AutomaticallyAddToCollection            = false
      
      TypeOptions = [{
        Type              = "Video"
        MetadataFetchers  = []
        ImageFetchers     = ["Embedded Image Extractor", "Screen Grabber"]
        ImageFetcherOrder = ["Embedded Image Extractor", "Screen Grabber"]
      }]
    }

    # =============================================================================
    # Photos - photo library settings
    # =============================================================================
    photos = {
      # Core settings (EnablePhotos must be true for photo libraries!)
      Enabled                                 = true
      EnablePhotos                            = true
      EnableRealtimeMonitor                   = true
      
      # Scanning and extraction (disable video processing)
      EnableLUFSScan                          = false
      EnableChapterImageExtraction            = false
      ExtractChapterImagesDuringLibraryScan   = false
      EnableTrickplayImageExtraction          = false
      ExtractTrickplayImagesDuringLibraryScan = false
      
      # Metadata
      SaveLocalMetadata                       = false
      EnableInternetProviders                 = false
      EnableAutomaticSeriesGrouping           = false
      EnableEmbeddedTitles                    = false
      EnableEmbeddedExtrasTitles              = false
      EnableEmbeddedEpisodeInfos              = false
      AutomaticRefreshIntervalDays            = 0
      
      # Subtitles (not relevant for photos)
      SkipSubtitlesIfEmbeddedSubtitlesPresent = true
      SkipSubtitlesIfAudioTrackMatches        = true
      SubtitleDownloadLanguages               = []
      RequirePerfectSubtitleMatch             = true
      SaveSubtitlesWithMedia                  = false
      AllowEmbeddedSubtitles                  = "AllowNone"
      
      # Other
      SaveLyricsWithMedia                     = false
      SaveTrickplayWithMedia                  = false
      PreferNonstandardArtistsTag             = false
      AutomaticallyAddToCollection            = false
      
      TypeOptions = [{
        Type             = "Photo"
        MetadataFetchers = []
        ImageFetchers    = []
      }]
    }

    # =============================================================================
    # Music - LUFS scanning, embedded artwork, lyrics
    # =============================================================================
    music = {
      # Core settings
      Enabled                                 = true
      EnablePhotos                            = true
      EnableRealtimeMonitor                   = true
      
      # Scanning and extraction (keep LUFS, disable video stuff)
      EnableLUFSScan                          = true
      EnableChapterImageExtraction            = false
      ExtractChapterImagesDuringLibraryScan   = false
      EnableTrickplayImageExtraction          = false
      ExtractTrickplayImagesDuringLibraryScan = false
      
      # Metadata
      SaveLocalMetadata                       = false
      EnableInternetProviders                 = false
      EnableAutomaticSeriesGrouping           = false
      EnableEmbeddedTitles                    = true
      EnableEmbeddedExtrasTitles              = false
      EnableEmbeddedEpisodeInfos              = false
      AutomaticRefreshIntervalDays            = 0
      
      # Subtitles (not relevant for music)
      SkipSubtitlesIfEmbeddedSubtitlesPresent = true
      SkipSubtitlesIfAudioTrackMatches        = true
      SubtitleDownloadLanguages               = []
      RequirePerfectSubtitleMatch             = true
      SaveSubtitlesWithMedia                  = false
      AllowEmbeddedSubtitles                  = "AllowNone"
      
      # Other (enable lyrics!)
      SaveLyricsWithMedia                     = true
      SaveTrickplayWithMedia                  = false
      PreferNonstandardArtistsTag             = true
      AutomaticallyAddToCollection            = false
      
      TypeOptions = [
        {
          Type              = "MusicAlbum"
          MetadataFetchers  = []
          ImageFetchers     = ["Embedded Image Extractor"]
          ImageFetcherOrder = ["Embedded Image Extractor"]
        },
        {
          Type             = "MusicArtist"
          MetadataFetchers = []
          ImageFetchers    = []
        },
        {
          Type              = "Audio"
          MetadataFetchers  = []
          ImageFetchers     = ["Embedded Image Extractor"]
          ImageFetcherOrder = ["Embedded Image Extractor"]
        }
      ]
    }

    # =============================================================================
    # Personal/private - same as homevideos, privacy-focused
    # =============================================================================
    personal = {
      # Core settings
      Enabled                                 = true
      EnablePhotos                            = true
      EnableRealtimeMonitor                   = true
      
      # Scanning and extraction
      EnableLUFSScan                          = false
      EnableChapterImageExtraction            = true
      ExtractChapterImagesDuringLibraryScan   = true
      EnableTrickplayImageExtraction          = true
      ExtractTrickplayImagesDuringLibraryScan = true
      
      # Metadata (no internet!)
      SaveLocalMetadata                       = false
      EnableInternetProviders                 = false
      EnableAutomaticSeriesGrouping           = false
      EnableEmbeddedTitles                    = true
      EnableEmbeddedExtrasTitles              = true
      EnableEmbeddedEpisodeInfos              = false
      AutomaticRefreshIntervalDays            = 0
      
      # Subtitles
      SkipSubtitlesIfEmbeddedSubtitlesPresent = true
      SkipSubtitlesIfAudioTrackMatches        = true
      SubtitleDownloadLanguages               = []
      RequirePerfectSubtitleMatch             = true
      SaveSubtitlesWithMedia                  = false
      AllowEmbeddedSubtitles                  = "AllowAll"
      
      # Other
      SaveLyricsWithMedia                     = false
      SaveTrickplayWithMedia                  = false
      PreferNonstandardArtistsTag             = false
      AutomaticallyAddToCollection            = false
      
      TypeOptions = [{
        Type              = "Video"
        MetadataFetchers  = []
        ImageFetchers     = ["Embedded Image Extractor", "Screen Grabber"]
        ImageFetcherOrder = ["Embedded Image Extractor", "Screen Grabber"]
      }]
    }
  }
}

variable "libraries" {
  description = <<-EOT
    Jellyfin media libraries to create.
    
    options_category determines which LibraryOptions template to use:
      - movies_metadata  : Full TMDB metadata, subtitles (de/en/ru), chapter images
      - tvshows_metadata : Full TMDB metadata for series/seasons/episodes
      - homevideos       : No external metadata, chapter/trickplay extraction
      - photos           : EnablePhotos=true, no video processing
      - music            : LUFS scanning, embedded artwork, lyrics
      - personal         : Privacy-focused, no external queries
  EOT

  type = map(object({
    display_name     = string
    group            = string
    collection_type  = string
    path             = string
    options_category = string
  }))

  default = {
    # ===========================================================================
    # VIDEO - Movies (with full TMDB metadata)
    # ===========================================================================
    "animated" = {
      display_name     = "Animated"
      group            = "video"
      collection_type  = "movies"
      path             = "/media/video/animated"
      options_category = "movies_metadata"
    }
    "anime" = {
      display_name     = "Anime"
      group            = "video"
      collection_type  = "movies"
      path             = "/media/video/anime"
      options_category = "movies_metadata"
    }
    "international_movies" = {
      display_name     = "International movies"
      group            = "video"
      collection_type  = "movies"
      path             = "/media/video/movies"
      options_category = "movies_metadata"
    }
    "e_movies" = {
      display_name     = "E movies"
      group            = "video"
      collection_type  = "movies"
      path             = "/media/video/e-movies"
      options_category = "movies_metadata"
    }
    "r_movies" = {
      display_name     = "Russian movies"
      group            = "video"
      collection_type  = "movies"
      path             = "/media/video/r-movies"
      options_category = "movies_metadata"
    }

    # ===========================================================================
    # VIDEO - TV Shows (with full TMDB metadata)
    # ===========================================================================
    "series" = {
      display_name     = "TV series"
      group            = "video"
      collection_type  = "tvshows"
      path             = "/media/video/series"
      options_category = "tvshows_metadata"
    }

    # ===========================================================================
    # VIDEO - Home Videos (local extraction only)
    # ===========================================================================
    "concerts" = {
      display_name     = "Concerts"
      group            = "video"
      collection_type  = "homevideos"
      path             = "/media/video/concerts"
      options_category = "homevideos"
    }
    "vacation-video" = {
      display_name     = "Vacation videos"
      group            = "video"
      collection_type  = "homevideos"
      path             = "/media/video/vacation"
      options_category = "homevideos"
    }

    # ===========================================================================
    # PHOTOS (EnablePhotos=true)
    # ===========================================================================
    "igor-photo" = {
      display_name     = "Igor's photos"
      group            = "photo"
      collection_type  = "homevideos"
      path             = "/media/photo/igor"
      options_category = "photos"
    }
    "mariia-photo" = {
      display_name     = "Mariia's photos"
      group            = "photo"
      collection_type  = "homevideos"
      path             = "/media/photo/mariia"
      options_category = "photos"
    }
    "yuliia-photo" = {
      display_name     = "Yuliia's photos"
      group            = "photo"
      collection_type  = "homevideos"
      path             = "/media/photo/yuliia"
      options_category = "photos"
    }
    "vacation-photo" = {
      display_name     = "Vacation photos"
      group            = "photo"
      collection_type  = "homevideos"
      path             = "/media/photo/vacation"
      options_category = "photos"
    }

    # ===========================================================================
    # MUSIC (LUFS scanning, embedded artwork)
    # ===========================================================================
    "music" = {
      display_name     = "Music"
      group            = "music"
      collection_type  = "music"
      path             = "/media/music"
      options_category = "music"
    }

    # ===========================================================================
    # PERSONAL (privacy-focused, no external metadata)
    # ===========================================================================
    "yuliia-pohudenije" = {
      display_name     = "Yuliia похудение"
      group            = "yuliia"
      collection_type  = "homevideos"
      path             = "/media/yuliia/похудение"
      options_category = "personal"
    }
    "yuliia-raznoe" = {
      display_name     = "Yuliia разное"
      group            = "yuliia"
      collection_type  = "homevideos"
      path             = "/media/yuliia/разное"
      options_category = "personal"
    }
  }
}
