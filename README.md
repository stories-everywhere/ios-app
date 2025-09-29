# StEve - Stories Everywhere - Abstract:
We present Stories Everywhere (StEve), a mobile Augmented Reality (AR) system designed to generate immersive, surreal audio narratives contextualized by the user’s surroundings. The system captures environmental data—including images of the surroundings, weather, and time—which is processed through a pipeline combining a Visual Question Answering, large language and text-to-speech model. This enables dynamic storytelling that integrates real-world elements into narratives delivered to the user whilst walking. We also introduce a preliminary exploration of whether our immersive AI-generated stories can maintain environmental awareness while being engaging. A prototype iOS application was developed and evaluated through small-scale situational tests and a case study. Results indicate that the system reliably integrates environmental cues into captivating audio stories, with participants reporting enjoyment and successful recognition of contextual elements. However, latency, connectivity, and model performance remain challenges for real-time immersion. This work demonstrates the feasibility of context-aware AR storytelling as a tool for enhancing attentiveness while maintaining entertainment value, and it outlines technical, experiential, and methodological directions for future research and refinement.

[Video explaination: [https://youtu.be/p4Ckd2ibXwI](https://youtu.be/p4Ckd2ibXwI) , more information on the pipeline can be found at: [https://github.com/stories-everywhere/python-pipeline.git](https://github.com/stories-everywhere/python-pipeline.git)]

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

## Get Weather Information
During the generation pipeline the app asyncronously get the location of the device and uses the https://openweathermap.org/api to get the description of the current weather. This is used to prompt the LLM

To use this feature you'll need an API key which you can save on a secret file and name it: ```weatherApiKey```


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

# Currently Working On:
- Weather and location only load sometimes
- Adding different styles of stories
