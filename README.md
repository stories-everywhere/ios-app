# Stories Everywhere iOS app
The core function of the app is the StoryGenerator class, which captures a video, extracts a frame, generates a story based on that frame, and plays back the story as audio. Here's a breakdown of the process:

## Capture Video
When generate() is called:

The app starts recording a short video using the VideoCapture class.

Once recording finishes, it saves the video file locally.

## Extract a Frame
After video recording:

A frame is extracted from the recorded video using AVAssetReader.

The first valid frame is saved and selected (chosenFrameURL).

### Generate a Story
Once a frame is selected:

The image is sent via multipart/form-data to a remote story-generation API (https://langate-story-api.onrender.com/generate-story).

Parameters like weather, length, and voice can be customized.

The API responds with a JSON object containing:

- A textual story
- Audio files (base64-encoded)
- Processing time
- Event metadata

### Play Audio
After story generation:

The first audio file is decoded from base64 and played using AVAudioPlayer.

A progress timer updates the UI during playback.

Playback controls (play, pause, stop) are available.

### Status Updates
The app updates the statusMessage string throughout the flow to reflect:

When recording starts

When frame extraction is happening

When the story is being generated or audio is playing

When errors occur

