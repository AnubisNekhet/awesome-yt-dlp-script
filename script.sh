#!/bin/sh
YTDL_FOLDER="$HOME/Media/Youtube/yt-dlp"

#==============================
# Awesome yt-dlp script!!!!!!!!
# Author: AnubisNekhet
# The Unlicense
#==============================

# Intro Card
gum style \
	--foreground 7 --border-foreground 1 --border double \
	--align center --width 50 --margin "0 1" --padding "1 1" \
	"Awesome $(gum style --foreground 1 "yt-dlp") script!!!!!!!!"

# Actions option
CHOICE=$(gum choose "download" "formats" "folder" "help" "downloads" --cursor.foreground 1 --header.foreground 4 --selected.foreground 1 --header "Choose action:")

case $CHOICE in
  "help") # Gives a list of all possible commands
      gum style \
	    --foreground 7 --border-foreground 7 --border normal \
	    --align center --width 50 --margin "1 1" --padding "0 1" \
      "$(gum style --foreground 1 "formats"): Display formats" \
      "$(gum style --foreground 1 "download"): Download video" \
      "$(gum style --foreground 1 "folder"): Open downloads folder" \
      "$(gum style --foreground 1 "downloads"): List downloads"
   ;;
  "folder") # Opens downloads folder
    open $YTDL_FOLDER && echo "Opening downloads folder..."
   ;;
  "downloads") # Lists file downloads
    exa $YTDL_FOLDER --tree --depth=1
   ;;
  "formats") # Lists formats for a video
    # Input video URL
    URL=$(gum input --header "Input URL: " --placeholder="https://www.youtube.com/watch?v=dQw4w9WgXcQ" --header.foreground 7 --cursor.foreground 1 --width 0)
    # Fetch video title, URL, channel and duration
    gum style \
	    --foreground 7 --border-foreground 4 --border double \
	    --align center --width 50 --margin "0 1" --padding "0 1" \
	    "$(yt-dlp $URL --print "%(title)s
[%(id)s]: %(duration_string)s
%(channel)s")"
      yt-dlp "$URL" -F
   ;;
  "download") # Downloads a video
    # Input video URL
    URL=$(gum input --header "Input URL: " --placeholder="https://www.youtube.com/watch?v=dQw4w9WgXcQ" --header.foreground 7 --cursor.foreground 1 --width 0)
    # Fetch video title, URL, channel and duration
    gum style \
	    --foreground 7 --border-foreground 4 --border double \
	    --align center --width 50 --margin "0 1" --padding "0 1" \
	    "$(yt-dlp $URL --print "%(title)s
[%(id)s]: %(duration_string)s
%(channel)s")"
    
    # Declare variables (I'm an absolute amateur in shell scripting)
    ARGS=""
    FORMAT=""
    POSTARGS=""
    # Select File Format
    FORMATLIST=$(gum choose "default" "bestformat" "bestaudio" "custom" --cursor.foreground 1 --header.foreground 4 --selected.foreground 1 --header "Choose file quality:")
    case $FORMATLIST in
    "bestformat")
      FORMAT="-S 'ext'"
    ;;
    "bestaudio")
      FORMAT="-f 'ba[ext=m4a]'"
    ;;
    "bestvideo")
      FORMAT="-f bestvideo"
    ;;
    "custom")
      FORMAT="-f $(gum input --header "Input format: " --placeholder="0" --header.foreground 7 --cursor.foreground 1 --width 0)"
    ;;
    esac
    # Select actions to perform
    ARGLIST=$(gum choose "portion" "thumbnail" "sponsorblock" "verbose" --no-limit --cursor.foreground 1 --header.foreground 4 --selected.foreground 1 --cursor-prefix "[ ] " --selected-prefix "[x] " --unselected-prefix "[ ] " --selected.foreground="2" --header "Choose action:")
    # Download specific portion of video
    if [[ $ARGLIST =~ "portion" ]]; then
      portionStart=$(gum input --header "Input start time: " --placeholder="0" --header.foreground 7 --cursor.foreground 1 --width 0)
      portionEnd=$(gum input --header "Input end time: " --placeholder="10" --header.foreground 7 --cursor.foreground 1 --width 0)
      ARGS+="--downloader ffmpeg --downloader-args \"ffmpeg_i:-ss $portionStart -to $portionEnd\" "
      echo "⏺ Splitting video..."
    fi
    # Embed Thumbnail
    if [[ $ARGLIST =~ "thumbnail" ]]; then
      ARGS+="--embed-thumbnail "
      echo "⏺ Embedding thumbnail..."
    fi
    # Add SponsorBlock
    if [[ $ARGLIST =~ "sponsorblock" ]]; then
      ARGS+="--sponsorblock-mark all --sponsorblock-remove selfpromo,interaction "
      echo "⏺ Adding SponsorBlock..."
    fi
    # Verbose logging toggle
    if [[ $ARGLIST =~ "verbose" ]]; then
      ARGLIST+=" "
    else
      ARGS+="-q --progress "
    fi

    # Select post-processing options
    PROCESSLIST=$(gum choose "no" "filetype" "rename" --no-limit --cursor.foreground 1 --header.foreground 4 --selected.foreground 1 --cursor-prefix "[ ] " --selected-prefix "[x] " --unselected-prefix "[ ] " --selected.foreground="2" --header "Do you want to post-process your videos?")
    # Select File Type to recode in
    if [[ $PROCESSLIST =~ "filetype" ]]
    then
      FILETYPE=$(gum choose "mp4" "mp3" "mkv" "webm" --cursor.foreground 1 --header.foreground 4 --selected.foreground 1 --header "Choose file format:")
      POSTARGS+="--recode-video $FILETYPE "
    fi
    # Rename file
    if [[ $PROCESSLIST =~ "rename" ]]
    then
      POSTARGS+="-o $(gum input --header "Video Title" --header.foreground 7 --cursor.foreground 1 --width 0).%(ext)s"
    fi
    yt-dlp "$URL" $ARGS $FORMAT $POSTARGS
    echo "Finished Downloading!"
     ;;
esac
