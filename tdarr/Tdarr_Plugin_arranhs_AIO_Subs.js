// tdarrSkipTest
const details = () => ({
  id: "Tdarr_Plugin_arranhs_AIO_Subs",
  Stage: "Pre-processing",
  Name: "All In One Subtitle Plugin",
  Type: "Video",
  Operation: "Transcode",
  Description: "",
  Version: "1.00",
  Tags: "pre-processing,subtitle only,ffmpeg,configurable",
  Inputs: [
    {
      name: "Extract Subs",
      type: "boolean",
      defaultValue: false,
      inputUI: {
        type: "dropdown",
        options: ["true", "false"],
      },
      tooltip: "Should subtitles be extracted",
    },
    {
      name: "Remove Subs",
      type: "boolean",
      defaultValue: false,
      inputUI: {
        type: "dropdown",
        options: ["true", "false"],
      },
      tooltip: "Should subtitles be removed",
    },
  ],
});

// eslint-disable-next-line no-unused-vars
const plugin = (file, librarySettings, inputs, otherArguments) => {
  const lib = require("../methods/lib")();
  const fs = require("fs");
  const path = require("path");

  // Load and check plugin inputs
  inputs = lib.loadDefaultValues(inputs, details);

  // Create response object
  const response = {
    processFile: false,
    preset: "",
    container: `.${file.container}`,
    handBrakeMode: false,
    FFmpegMode: true,
    reQueueAfter: true,
    infoLog: "",
  };

  // Get inputs
  const extract = inputs["Extract Subs"];
  const remove = inputs["Remove Subs"];

  // Encoding arguments
  // https://ffmpeg.org/ffmpeg.html
  const encodingArgs = ["<io>"];

  let rootInputDir = librarySettings.folder;
  let rootOutputDir = librarySettings.output
    ? librarySettings.output
    : librarySettings.folder;

  // Source file details
  let sourceFilePath = otherArguments.originalLibraryFile.file;
  let sourceFileLabel = path.basename(sourceFilePath, path.extname(sourceFilePath));

  // Output folder details
  let subDirs = path.relative(rootInputDir, path.dirname(sourceFilePath));
  let outputDir = path.join(rootOutputDir, subDirs);

  // Create output folder
  fs.mkdirSync(outputDir, { recursive: true });

  response.infoLog += `Outputting subtitles to ${outputDir}!\n`;

  // Current sun stream idx
  let subIdx = -1;
  // Object of subtitle files to number of times seen
  const seenSubFileNames = {};
  // Number of subtitles to extract
  let numSubsToExtract = 0;

  // Go through each stream in the file
  for (let i = 0; i < file.ffProbeData.streams.length; i++) {
    const stream = file.ffProbeData.streams[i];

    // If stream is not a sub stream, skip it
    if (stream.codec_name.toLowerCase() !== "subrip") {
      continue;
    }

    // Increment sub stream index
    subIdx += 1;

    // Sub extension. This will be updated
    let subFileExtension = ".srt";

    // Get sub track title
    if (stream && stream.tags && stream.tags.title) {
      let title = stream.tags.title;
      let titleLower = title.toLowerCase();

      // Skip commentary and description sub tracks
      if (
        titleLower.includes("commentary") ||
        titleLower.includes("description")
      ) {
        response.infoLog += `Subtitle ${subIdx} is a ${title} subtitle. Skipping!\n`;
        continue;
      }

      // Add .hi to extension of hering imoared tracks
      let hiRegex = /\b(sdh|hi|cc)\b/g;
      if (hiRegex.test(titleLower)) {
        response.infoLog += `Subtitle ${subIdx} is a hearing impaired subtitle.\n`;
        subFileExtension = ".hi" + subFileExtension;
      }
    }

    // Get subtitle language
    if (stream.tags && stream.tags.language) {
      let lang = stream.tags.language;
      subFileExtension = `.${lang}` + subFileExtension;
    }

    // Get sub file name
    let subFileName = sourceFileLabel + subFileExtension;

    // If sub file name has been seen, add index to name
    let timesSeen = seenSubFileNames[subFileName];
    if (timesSeen) {
      timesSeen += 1;
      subFileName = `.${timesSeen}` + subFileName;
      seenSubFileNames[subFileName] = timesSeen;
    } else {
      seenSubFileNames[subFileName] = 1;
    }

    // Output sub file path
    let subFilePath = path.join(outputDir, subFileName);
    if (fs.existsSync(subFilePath)) {
      response.infoLog += `${subFileName} already exists. Skipping!\n`;
      continue;
    }

    // Map sub stream to a file
    encodingArgs.push(`-map 0:s:${subIdx} "${subFilePath}"`);

    // Increment the number of subs to extract
    numSubsToExtract += 1;
  }

  if (subIdx !== -1) {
    response.infoLog += `Found ${subIdx + 1} subs to extract!\n`;
  } else {
    response.infoLog += "No subs found to extract!\n";
    return response;
  }

  if (numSubsToExtract) {
    response.infoLog += `Extracting ${numSubsToExtract} subs!\n`;
  } else {
    response.infoLog += "All subs as already extracted!\n";
    return response;
  }

  // if (inputs.remove_subs === "yes") {
  //   response.preset += " -map 0 -map -0:s -c copy";
  // }

  // if (inputs.remove_subs === "no") {
  //   response.preset += " -map 0 -c copy";
  // }

  // Map ALL streams from the input file to output file
  encodingArgs.push("-map 0");
  // Copy the streams from the input file to the output file
  encodingArgs.push("-c copy");

  // Update response object
  response.infoLog += "File is being transcoded\n";
  response.processFile = true;
  response.preset = encodingArgs.join(" ");

  return response;
};

module.exports.details = details;
module.exports.plugin = plugin;
