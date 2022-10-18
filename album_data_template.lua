--[[

This template file shows you how to populate the data structures for
music, lyrics and art. Hopefully it is pretty self explanatory.

Audio file will be a wav file or something else that playdate knows 
about, but don't include the file extension in the filename here. The
playdate compiler wrangles the audio files somehow, and doesn't want
the extension at load time.

The art files can be anything that playdate knows how to load into
a playdate image. I have used pngs produced by dropping art straight
into https://strike.amorphic.space/, which I found procudes 1-bit 
art I like.

--]]

local songs = 
{
    {
        lyrics = import("a_lyric_file.lua"),
        audio = "an_audio_file",
        title = "The Track's Title",
    },
    {
        lyrics = import("another_lyric_file.lua"),
        audio = "another_audio_file",
        title = "Track Two's Title",
    },

    -- etc...
}


local art =
{
    {
        file = "some-monochrome-art.png",
        x = -1810,      -- x offset of top left corner of the image when it is first displayed
        y = -372,       -- y offset of top left corner of the image when it is first displayed
        w = 4000,       -- width
        h = 4000,       -- height
    },
    {
        file = "band-photo-1bit.png",
        x = -1810,
        y = -372,
        w = 4568,
        h = 3426,
    },
    
    -- etc...
}

local about =
{
    text = import("about.lua"),
}

local help =
{
    text = import("help.lua"),
}


return songs, art, about, help