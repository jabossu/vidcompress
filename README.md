# vidcompress
A simple wrapper bash script that will ease my use of ffmpeg.

## What does it do ?
I use ffmpeg a lot. I often get large movie files encoded with old and inneficient codecs, and as i'm trying to save space on my hard drive, i like to re-encode them with the h265 codec using ffmpeg.

But the command is a little bit tedious to my taste, especially considering i almost always use the same one. So i wrote this script to shorten it and ease the encoding process.

## How to use this script ?
* Download it (or clone it) and make it executable. You might consider adding it to your path.
* Check that you have ffmpeg installed along with the libx265 codec, and that ffmpeg has the `--enable-libx265` flag enabled.
* use `vidcompress -h` to get an idea of the syntax and options

## Note
I wrote this script for my own use. It's probably poorly written, very un-elegant and very much improvable, but i dont really care. I would be pleased to read suggestion and tricks to improve this script, but don't feel offended ~~when~~ if I don't edit it, or even answer your comments. I just posted it here because I enjoy putting my stuff on github.
Thank you very much :-)
