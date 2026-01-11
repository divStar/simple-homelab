# Jellyfin Web UI OIDC

This module uses the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary `client_id`
to set up OIDC/OAuth for Jellyfin (dashboard) with Zitadel.

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Modules](#modules) _(nested and adjacent)_
  - [jellyfin_web_ui_oidc](#jellyfin_web_ui_oidc)
- [Resources](#resources)
  - _terracurl_request_.[jellyfin_auth](#terracurl_requestjellyfin_auth)
  - _terracurl_request_.[jellyfin_branding](#terracurl_requestjellyfin_branding)
  - _terracurl_request_.[jellyfin_complete_wizard](#terracurl_requestjellyfin_complete_wizard)
  - _terracurl_request_.[jellyfin_get_libraries](#terracurl_requestjellyfin_get_libraries)
  - _terracurl_request_.[jellyfin_get_startup_user](#terracurl_requestjellyfin_get_startup_user)
  - _terracurl_request_.[jellyfin_install_plugins](#terracurl_requestjellyfin_install_plugins)
  - _terracurl_request_.[jellyfin_libraries](#terracurl_requestjellyfin_libraries)
  - _terracurl_request_.[jellyfin_restart_issued](#terracurl_requestjellyfin_restart_issued)
  - _terracurl_request_.[jellyfin_scan_libraries](#terracurl_requestjellyfin_scan_libraries)
  - _terracurl_request_.[jellyfin_setup_plugin_repositories](#terracurl_requestjellyfin_setup_plugin_repositories)
  - _terracurl_request_.[jellyfin_sso](#terracurl_requestjellyfin_sso)
  - _terracurl_request_.[jellyfin_startup_configuration](#terracurl_requestjellyfin_startup_configuration)
  - _terracurl_request_.[jellyfin_startup_user](#terracurl_requestjellyfin_startup_user)
  - _time_sleep_.[jellyfin_restart_completed](#time_sleepjellyfin_restart_completed)
- [Variables](#variables)
  - [admin_password](#admin_password-required) (**Required**)
  - [admin_username](#admin_username-optional) (*Optional*)
  - [libraries](#libraries-optional) (*Optional*)
  - [library_options_templates](#library_options_templates-optional) (*Optional*)
  - [plugin_repositories](#plugin_repositories-optional) (*Optional*)
  - [plugins](#plugins-optional) (*Optional*)
- [Outputs](#outputs)
  - [auth_header](#auth_header)
  - [client_id](#client_id)
  - [folder_role_mapping](#folder_role_mapping)
  - [library_ids](#library_ids)
</blockquote><!-- contents:end -->

## Providers
![OpenTofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)
![devops-rob/terracurl](https://img.shields.io/badge/devops-rob--terracurl->=1.2.1-d52a7f?logo=terracurl)
![hashicorp/time](https://img.shields.io/badge/hashicorp--time->=0.13.1-b0055a?logo=time)
![zitadel](https://img.shields.io/badge/zitadel->=2.5.0-ee4398?logo=zitadel)

## Modules
  
<blockquote><!-- module:"jellyfin_web_ui_oidc":start -->

### `jellyfin_web_ui_oidc`

Call to the OIDC module to create the necessary resources in Zitadel.
  <table>
    <tr>
      <td>Module location</td>
      <td><code>../../../common/modules/oidc</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L325"><code>main.tf#L325</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="../../../common/modules/oidc/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"jellyfin_web_ui_oidc":end -->

## Resources
  
<blockquote><!-- resource:"terracurl_request.jellyfin_auth":start -->

### _terracurl_request_.`jellyfin_auth`

Authenticate to get an access token
  <table>
    <tr>
      <td>Provider</td>
      <td><code>terracurl (devops-rob/terracurl)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L186"><code>main.tf#L186</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"terracurl_request.jellyfin_auth":end -->
<blockquote><!-- resource:"terracurl_request.jellyfin_branding":start -->

### _terracurl_request_.`jellyfin_branding`

Add the "Login with Zitadel" SSO button as a Login disclaimer branding configuration
  <table>
    <tr>
      <td>Provider</td>
      <td><code>terracurl (devops-rob/terracurl)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L390"><code>main.tf#L390</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"terracurl_request.jellyfin_branding":end -->
<blockquote><!-- resource:"terracurl_request.jellyfin_complete_wizard":start -->

### _terracurl_request_.`jellyfin_complete_wizard`

Step 4: Complete the startup wizard
  <table>
    <tr>
      <td>Provider</td>
      <td><code>terracurl (devops-rob/terracurl)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L164"><code>main.tf#L164</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"terracurl_request.jellyfin_complete_wizard":end -->
<blockquote><!-- resource:"terracurl_request.jellyfin_get_libraries":start -->

### _terracurl_request_.`jellyfin_get_libraries`

Retrieve library IDs from Jellyfin
  <table>
    <tr>
      <td>Provider</td>
      <td><code>terracurl (devops-rob/terracurl)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L310"><code>main.tf#L310</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"terracurl_request.jellyfin_get_libraries":end -->
<blockquote><!-- resource:"terracurl_request.jellyfin_get_startup_user":start -->

### _terracurl_request_.`jellyfin_get_startup_user`

Step 2: GET the startup user (this creates the initial user internally!)
  <table>
    <tr>
      <td>Provider</td>
      <td><code>terracurl (devops-rob/terracurl)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L127"><code>main.tf#L127</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"terracurl_request.jellyfin_get_startup_user":end -->
<blockquote><!-- resource:"terracurl_request.jellyfin_install_plugins":start -->

### _terracurl_request_.`jellyfin_install_plugins`

Install Jellyfin plugins
  <table>
    <tr>
      <td>Provider</td>
      <td><code>terracurl (devops-rob/terracurl)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L225"><code>main.tf#L225</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"terracurl_request.jellyfin_install_plugins":end -->
<blockquote><!-- resource:"terracurl_request.jellyfin_libraries":start -->

### _terracurl_request_.`jellyfin_libraries`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>terracurl (devops-rob/terracurl)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L251"><code>main.tf#L251</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"terracurl_request.jellyfin_libraries":end -->
<blockquote><!-- resource:"terracurl_request.jellyfin_restart_issued":start -->

### _terracurl_request_.`jellyfin_restart_issued`

Restart Jellyfin
  <table>
    <tr>
      <td>Provider</td>
      <td><code>terracurl (devops-rob/terracurl)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L287"><code>main.tf#L287</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"terracurl_request.jellyfin_restart_issued":end -->
<blockquote><!-- resource:"terracurl_request.jellyfin_scan_libraries":start -->

### _terracurl_request_.`jellyfin_scan_libraries`

Initiate the scan of all created libraries
  <table>
    <tr>
      <td>Provider</td>
      <td><code>terracurl (devops-rob/terracurl)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L410"><code>main.tf#L410</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"terracurl_request.jellyfin_scan_libraries":end -->
<blockquote><!-- resource:"terracurl_request.jellyfin_setup_plugin_repositories":start -->

### _terracurl_request_.`jellyfin_setup_plugin_repositories`

Setup Jellyfin plugin repositories
  <table>
    <tr>
      <td>Provider</td>
      <td><code>terracurl (devops-rob/terracurl)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L207"><code>main.tf#L207</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"terracurl_request.jellyfin_setup_plugin_repositories":end -->
<blockquote><!-- resource:"terracurl_request.jellyfin_sso":start -->

### _terracurl_request_.`jellyfin_sso`

Configure the SSO plugin with Zitadel OIDC details
  <table>
    <tr>
      <td>Provider</td>
      <td><code>terracurl (devops-rob/terracurl)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L357"><code>main.tf#L357</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"terracurl_request.jellyfin_sso":end -->
<blockquote><!-- resource:"terracurl_request.jellyfin_startup_configuration":start -->

### _terracurl_request_.`jellyfin_startup_configuration`

Step 1: Set initial server configuration
  <table>
    <tr>
      <td>Provider</td>
      <td><code>terracurl (devops-rob/terracurl)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L106"><code>main.tf#L106</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"terracurl_request.jellyfin_startup_configuration":end -->
<blockquote><!-- resource:"terracurl_request.jellyfin_startup_user":start -->

### _terracurl_request_.`jellyfin_startup_user`

Step 3: Set the admin username and password
  <table>
    <tr>
      <td>Provider</td>
      <td><code>terracurl (devops-rob/terracurl)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L143"><code>main.tf#L143</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"terracurl_request.jellyfin_startup_user":end -->
<blockquote><!-- resource:"time_sleep.jellyfin_restart_completed":start -->

### _time_sleep_.`jellyfin_restart_completed`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>time (hashicorp/time)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L303"><code>main.tf#L303</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"time_sleep.jellyfin_restart_completed":end -->

## Variables
  
<blockquote><!-- variable:"admin_password":start -->

### `admin_password` (**Required**)

Admin password for Jellyfin initial setup

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L7"><code>variables.tf#L7</code></a>

</details>
</blockquote><!-- variable:"admin_password":end -->
<blockquote><!-- variable:"admin_username":start -->

### `admin_username` (*Optional*)

Admin username for Jellyfin initial setup

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "admin"
  ```
  In file: <a href="./variables.tf#L1"><code>variables.tf#L1</code></a>

</details>
</blockquote><!-- variable:"admin_username":end -->
<blockquote><!-- variable:"libraries":start -->

### `libraries` (*Optional*)

Jellyfin media libraries to create.
    
options_category determines which LibraryOptions template to use:
  - movies_metadata  : Full TMDB metadata, subtitles (de/en/ru), chapter images
  - tvshows_metadata : Full TMDB metadata for series/seasons/episodes
  - homevideos       : No external metadata, chapter/trickplay extraction
  - photos           : EnablePhotos=true, no video processing
  - music            : LUFS scanning, embedded artwork, lyrics
  - personal         : Privacy-focused, no external queries


<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  map(object({
    display_name     = string
    group            = string
    collection_type  = string
    path             = string
    options_category = string
  }))
  ```
  **Default**:
  ```json
  {
  "animated": {
    "collection_type": "movies",
    "display_name": "Animated",
    "group": "video",
    "options_category": "movies_metadata",
    "path": "/media/video/animated"
  },
  "anime": {
    "collection_type": "movies",
    "display_name": "Anime",
    "group": "video",
    "options_category": "movies_metadata",
    "path": "/media/video/anime"
  },
  "concerts": {
    "collection_type": "homevideos",
    "display_name": "Concerts",
    "group": "video",
    "options_category": "homevideos",
    "path": "/media/video/concerts"
  },
  "e_movies": {
    "collection_type": "movies",
    "display_name": "E movies",
    "group": "video",
    "options_category": "movies_metadata",
    "path": "/media/video/e-movies"
  },
  "igor-photo": {
    "collection_type": "homevideos",
    "display_name": "Igor's photos",
    "group": "photo",
    "options_category": "photos",
    "path": "/media/photo/igor"
  },
  "international_movies": {
    "collection_type": "movies",
    "display_name": "International movies",
    "group": "video",
    "options_category": "movies_metadata",
    "path": "/media/video/movies"
  },
  "mariia-photo": {
    "collection_type": "homevideos",
    "display_name": "Mariia's photos",
    "group": "photo",
    "options_category": "photos",
    "path": "/media/photo/mariia"
  },
  "music": {
    "collection_type": "music",
    "display_name": "Music",
    "group": "music",
    "options_category": "music",
    "path": "/media/music"
  },
  "r_movies": {
    "collection_type": "movies",
    "display_name": "Russian movies",
    "group": "video",
    "options_category": "movies_metadata",
    "path": "/media/video/r-movies"
  },
  "series": {
    "collection_type": "tvshows",
    "display_name": "TV series",
    "group": "video",
    "options_category": "tvshows_metadata",
    "path": "/media/video/series"
  },
  "vacation-photo": {
    "collection_type": "homevideos",
    "display_name": "Vacation photos",
    "group": "photo",
    "options_category": "photos",
    "path": "/media/photo/vacation"
  },
  "vacation-video": {
    "collection_type": "homevideos",
    "display_name": "Vacation videos",
    "group": "video",
    "options_category": "homevideos",
    "path": "/media/video/vacation"
  },
  "yuliia-photo": {
    "collection_type": "homevideos",
    "display_name": "Yuliia's photos",
    "group": "photo",
    "options_category": "photos",
    "path": "/media/photo/yuliia"
  },
  "yuliia-pohudenije": {
    "collection_type": "homevideos",
    "display_name": "Yuliia похудение",
    "group": "yuliia",
    "options_category": "personal",
    "path": "/media/yuliia/похудение"
  },
  "yuliia-raznoe": {
    "collection_type": "homevideos",
    "display_name": "Yuliia разное",
    "group": "yuliia",
    "options_category": "personal",
    "path": "/media/yuliia/разное"
  }
}
  ```
  In file: <a href="./variables.tf#L377"><code>variables.tf#L377</code></a>

</details>
</blockquote><!-- variable:"libraries":end -->
<blockquote><!-- variable:"library_options_templates":start -->

### `library_options_templates` (*Optional*)

Library options templates with explicit values for all relevant properties

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  any
  ```
  **Default**:
  ```json
  {
  "homevideos": {
    "AllowEmbeddedSubtitles": "AllowAll",
    "AutomaticRefreshIntervalDays": 0,
    "AutomaticallyAddToCollection": false,
    "EnableAutomaticSeriesGrouping": false,
    "EnableChapterImageExtraction": true,
    "EnableEmbeddedEpisodeInfos": false,
    "EnableEmbeddedExtrasTitles": true,
    "EnableEmbeddedTitles": true,
    "EnableInternetProviders": false,
    "EnableLUFSScan": false,
    "EnablePhotos": true,
    "EnableRealtimeMonitor": true,
    "EnableTrickplayImageExtraction": true,
    "Enabled": true,
    "ExtractChapterImagesDuringLibraryScan": true,
    "ExtractTrickplayImagesDuringLibraryScan": true,
    "PreferNonstandardArtistsTag": false,
    "RequirePerfectSubtitleMatch": true,
    "SaveLocalMetadata": false,
    "SaveLyricsWithMedia": false,
    "SaveSubtitlesWithMedia": false,
    "SaveTrickplayWithMedia": false,
    "SkipSubtitlesIfAudioTrackMatches": true,
    "SkipSubtitlesIfEmbeddedSubtitlesPresent": true,
    "SubtitleDownloadLanguages": [],
    "TypeOptions": [
      {
        "ImageFetcherOrder": [
          "Embedded Image Extractor",
          "Screen Grabber"
        ],
        "ImageFetchers": [
          "Embedded Image Extractor",
          "Screen Grabber"
        ],
        "MetadataFetchers": [],
        "Type": "Video"
      }
    ]
  },
  "movies_metadata": {
    "AllowEmbeddedSubtitles": "AllowAll",
    "AutomaticRefreshIntervalDays": 30,
    "AutomaticallyAddToCollection": true,
    "EnableAutomaticSeriesGrouping": false,
    "EnableChapterImageExtraction": true,
    "EnableEmbeddedEpisodeInfos": false,
    "EnableEmbeddedExtrasTitles": true,
    "EnableEmbeddedTitles": true,
    "EnableInternetProviders": true,
    "EnableLUFSScan": false,
    "EnablePhotos": true,
    "EnableRealtimeMonitor": true,
    "EnableTrickplayImageExtraction": true,
    "Enabled": true,
    "ExtractChapterImagesDuringLibraryScan": true,
    "ExtractTrickplayImagesDuringLibraryScan": true,
    "PreferNonstandardArtistsTag": false,
    "RequirePerfectSubtitleMatch": true,
    "SaveLocalMetadata": false,
    "SaveLyricsWithMedia": false,
    "SaveSubtitlesWithMedia": true,
    "SaveTrickplayWithMedia": false,
    "SkipSubtitlesIfAudioTrackMatches": true,
    "SkipSubtitlesIfEmbeddedSubtitlesPresent": true,
    "SubtitleDownloadLanguages": [
      "ger",
      "eng",
      "rus"
    ],
    "TypeOptions": [
      {
        "ImageFetcherOrder": [
          "TheMovieDb"
        ],
        "ImageFetchers": [
          "TheMovieDb"
        ],
        "MetadataFetcherOrder": [
          "TheMovieDb"
        ],
        "MetadataFetchers": [
          "TheMovieDb"
        ],
        "Type": "Movie"
      }
    ]
  },
  "music": {
    "AllowEmbeddedSubtitles": "AllowNone",
    "AutomaticRefreshIntervalDays": 0,
    "AutomaticallyAddToCollection": false,
    "EnableAutomaticSeriesGrouping": false,
    "EnableChapterImageExtraction": false,
    "EnableEmbeddedEpisodeInfos": false,
    "EnableEmbeddedExtrasTitles": false,
    "EnableEmbeddedTitles": true,
    "EnableInternetProviders": false,
    "EnableLUFSScan": true,
    "EnablePhotos": true,
    "EnableRealtimeMonitor": true,
    "EnableTrickplayImageExtraction": false,
    "Enabled": true,
    "ExtractChapterImagesDuringLibraryScan": false,
    "ExtractTrickplayImagesDuringLibraryScan": false,
    "PreferNonstandardArtistsTag": true,
    "RequirePerfectSubtitleMatch": true,
    "SaveLocalMetadata": false,
    "SaveLyricsWithMedia": true,
    "SaveSubtitlesWithMedia": false,
    "SaveTrickplayWithMedia": false,
    "SkipSubtitlesIfAudioTrackMatches": true,
    "SkipSubtitlesIfEmbeddedSubtitlesPresent": true,
    "SubtitleDownloadLanguages": [],
    "TypeOptions": [
      {
        "ImageFetcherOrder": [
          "Embedded Image Extractor"
        ],
        "ImageFetchers": [
          "Embedded Image Extractor"
        ],
        "MetadataFetchers": [],
        "Type": "MusicAlbum"
      },
      {
        "ImageFetchers": [],
        "MetadataFetchers": [],
        "Type": "MusicArtist"
      },
      {
        "ImageFetcherOrder": [
          "Embedded Image Extractor"
        ],
        "ImageFetchers": [
          "Embedded Image Extractor"
        ],
        "MetadataFetchers": [],
        "Type": "Audio"
      }
    ]
  },
  "personal": {
    "AllowEmbeddedSubtitles": "AllowAll",
    "AutomaticRefreshIntervalDays": 0,
    "AutomaticallyAddToCollection": false,
    "EnableAutomaticSeriesGrouping": false,
    "EnableChapterImageExtraction": true,
    "EnableEmbeddedEpisodeInfos": false,
    "EnableEmbeddedExtrasTitles": true,
    "EnableEmbeddedTitles": true,
    "EnableInternetProviders": false,
    "EnableLUFSScan": false,
    "EnablePhotos": true,
    "EnableRealtimeMonitor": true,
    "EnableTrickplayImageExtraction": true,
    "Enabled": true,
    "ExtractChapterImagesDuringLibraryScan": true,
    "ExtractTrickplayImagesDuringLibraryScan": true,
    "PreferNonstandardArtistsTag": false,
    "RequirePerfectSubtitleMatch": true,
    "SaveLocalMetadata": false,
    "SaveLyricsWithMedia": false,
    "SaveSubtitlesWithMedia": false,
    "SaveTrickplayWithMedia": false,
    "SkipSubtitlesIfAudioTrackMatches": true,
    "SkipSubtitlesIfEmbeddedSubtitlesPresent": true,
    "SubtitleDownloadLanguages": [],
    "TypeOptions": [
      {
        "ImageFetcherOrder": [
          "Embedded Image Extractor",
          "Screen Grabber"
        ],
        "ImageFetchers": [
          "Embedded Image Extractor",
          "Screen Grabber"
        ],
        "MetadataFetchers": [],
        "Type": "Video"
      }
    ]
  },
  "photos": {
    "AllowEmbeddedSubtitles": "AllowNone",
    "AutomaticRefreshIntervalDays": 0,
    "AutomaticallyAddToCollection": false,
    "EnableAutomaticSeriesGrouping": false,
    "EnableChapterImageExtraction": false,
    "EnableEmbeddedEpisodeInfos": false,
    "EnableEmbeddedExtrasTitles": false,
    "EnableEmbeddedTitles": false,
    "EnableInternetProviders": false,
    "EnableLUFSScan": false,
    "EnablePhotos": true,
    "EnableRealtimeMonitor": true,
    "EnableTrickplayImageExtraction": false,
    "Enabled": true,
    "ExtractChapterImagesDuringLibraryScan": false,
    "ExtractTrickplayImagesDuringLibraryScan": false,
    "PreferNonstandardArtistsTag": false,
    "RequirePerfectSubtitleMatch": true,
    "SaveLocalMetadata": false,
    "SaveLyricsWithMedia": false,
    "SaveSubtitlesWithMedia": false,
    "SaveTrickplayWithMedia": false,
    "SkipSubtitlesIfAudioTrackMatches": true,
    "SkipSubtitlesIfEmbeddedSubtitlesPresent": true,
    "SubtitleDownloadLanguages": [],
    "TypeOptions": [
      {
        "ImageFetchers": [],
        "MetadataFetchers": [],
        "Type": "Photo"
      }
    ]
  },
  "tvshows_metadata": {
    "AllowEmbeddedSubtitles": "AllowAll",
    "AutomaticRefreshIntervalDays": 7,
    "AutomaticallyAddToCollection": true,
    "EnableAutomaticSeriesGrouping": true,
    "EnableChapterImageExtraction": true,
    "EnableEmbeddedEpisodeInfos": true,
    "EnableEmbeddedExtrasTitles": true,
    "EnableEmbeddedTitles": true,
    "EnableInternetProviders": true,
    "EnableLUFSScan": false,
    "EnablePhotos": true,
    "EnableRealtimeMonitor": true,
    "EnableTrickplayImageExtraction": true,
    "Enabled": true,
    "ExtractChapterImagesDuringLibraryScan": true,
    "ExtractTrickplayImagesDuringLibraryScan": true,
    "PreferNonstandardArtistsTag": false,
    "RequirePerfectSubtitleMatch": true,
    "SaveLocalMetadata": false,
    "SaveLyricsWithMedia": false,
    "SaveSubtitlesWithMedia": true,
    "SaveTrickplayWithMedia": false,
    "SkipSubtitlesIfAudioTrackMatches": true,
    "SkipSubtitlesIfEmbeddedSubtitlesPresent": true,
    "SubtitleDownloadLanguages": [
      "ger",
      "eng",
      "rus"
    ],
    "TypeOptions": [
      {
        "ImageFetcherOrder": [
          "TheMovieDb"
        ],
        "ImageFetchers": [
          "TheMovieDb"
        ],
        "MetadataFetcherOrder": [
          "TheMovieDb"
        ],
        "MetadataFetchers": [
          "TheMovieDb"
        ],
        "Type": "Series"
      },
      {
        "ImageFetcherOrder": [
          "TheMovieDb"
        ],
        "ImageFetchers": [
          "TheMovieDb"
        ],
        "MetadataFetcherOrder": [
          "TheMovieDb"
        ],
        "MetadataFetchers": [
          "TheMovieDb"
        ],
        "Type": "Season"
      },
      {
        "ImageFetcherOrder": [
          "TheMovieDb",
          "Embedded Image Extractor",
          "Screen Grabber"
        ],
        "ImageFetchers": [
          "TheMovieDb",
          "Embedded Image Extractor",
          "Screen Grabber"
        ],
        "MetadataFetcherOrder": [
          "TheMovieDb"
        ],
        "MetadataFetchers": [
          "TheMovieDb"
        ],
        "Type": "Episode"
      }
    ]
  }
}
  ```
  In file: <a href="./variables.tf#L57"><code>variables.tf#L57</code></a>

</details>
</blockquote><!-- variable:"library_options_templates":end -->
<blockquote><!-- variable:"plugin_repositories":start -->

### `plugin_repositories` (*Optional*)

Repositories to set up and enable

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  list(object({
    Name    = string
    Url     = string
    Enabled = bool
  }))
  ```
  **Default**:
  ```json
  [
  {
    "Enabled": true,
    "Name": "Jellyfin Stable",
    "Url": "https://repo.jellyfin.org/files/plugin/manifest.json"
  },
  {
    "Enabled": true,
    "Name": "9p4 SSO",
    "Url": "https://raw.githubusercontent.com/9p4/jellyfin-plugin-sso/manifest-release/manifest.json"
  }
]
  ```
  In file: <a href="./variables.tf#L13"><code>variables.tf#L13</code></a>

</details>
</blockquote><!-- variable:"plugin_repositories":end -->
<blockquote><!-- variable:"plugins":start -->

### `plugins` (*Optional*)

Plugins to install

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  map(object({
    name          = string
    assembly_guid = string
    repository    = string
  }))
  ```
  **Default**:
  ```json
  {
  "dlna": {
    "assembly_guid": "33eba9cd-7da1-4720-967f-dd7dae7b74a1",
    "name": "DLNA",
    "repository": "https://repo.jellyfin.org/files/plugin/manifest.json"
  },
  "sso": {
    "assembly_guid": "505ce9d1-d916-42fa-86ca-673ef241d7df",
    "name": "SSO Authentication",
    "repository": "https://raw.githubusercontent.com/9p4/jellyfin-plugin-sso/manifest-release/manifest.json"
  }
}
  ```
  In file: <a href="./variables.tf#L35"><code>variables.tf#L35</code></a>

</details>
</blockquote><!-- variable:"plugins":end -->

## Outputs
  
<blockquote><!-- output:"auth_header":start -->

#### `auth_header`

Jellyfin MediaBrowser header

In file: <a href="./main.tf#L445"><code>main.tf#L445</code></a>
</blockquote><!-- output:"auth_header":end -->
<blockquote><!-- output:"client_id":start -->

#### `client_id`

Jellyfin Client ID

In file: <a href="./main.tf#L427"><code>main.tf#L427</code></a>
</blockquote><!-- output:"client_id":end -->
<blockquote><!-- output:"folder_role_mapping":start -->

#### `folder_role_mapping`

Jellyfin folder-role-mapping

In file: <a href="./main.tf#L439"><code>main.tf#L439</code></a>
</blockquote><!-- output:"folder_role_mapping":end -->
<blockquote><!-- output:"library_ids":start -->

#### `library_ids`

Jellyfin library IDs

In file: <a href="./main.tf#L433"><code>main.tf#L433</code></a>
</blockquote><!-- output:"library_ids":end -->