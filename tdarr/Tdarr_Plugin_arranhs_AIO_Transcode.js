const details = () => ({
  id: "Tdarr_Plugin_arranhs_AIO_Transcode",
  Stage: "Pre-processing",
  Name: "All In One Transcode Plugin",
  Type: "Video",
  Operation: "Transcode",
  Description: `
  [Contains built-in filter]\\n
  This all-in-one plugin allows a high level of ffmpeg transcode configuration using presets.\\n
  Plugin will only transcode if files are not HEVC.\\n
  Output container is mkv.
  `,
  Version: "1.00",
  Tags: "pre-processing,ffmpeg,video only,h265,configurable",
  Inputs: [
    {
      name: "Preset",
      type: "string",
      defaultValue: "slow",
      inputUI: {
        type: "dropdown",
        options: [
          "ultrafast",
          "superfast",
          "veryfast",
          "faster",
          "fast",
          "medium",
          "slow",
          "slower",
          "veryslow",
          "placebo",
        ],
      },
      tooltip: `
    Select the ffmpeg preset you want to use.\\n
    For more info, see https://x265.readthedocs.io/en/stable/presets.html#presets
    `,
    },
    {
      name: "Tuning",
      type: "string",
      defaultValue: "",
      inputUI: {
        type: "dropdown",
        options: [
          "",
          "psnr",
          "ssim",
          "grain",
          "fastdecode",
          "zerolatency",
          "animation",
        ],
      },
      tooltip: `
      Specify the tuning option you want to use.\\n
      Leave blank to use no tuning option.\\n
      - psnr:        Disables adaptive quant, psy-rd, and cutree.\\n
      - ssim:        Enables adaptive quant auto-mode, disables psy-rd.\\n
      - grain:       Improves retention of film grain.\\n
      - fastdecode:  No loop filters, no weighted pred, no intra in B.\\n
      - zerolatency: No lookahead, no B frames, no cutree.\\n
      - animation:   Improves encode quality for animated content.\\n
      For more info, see https://x265.readthedocs.io/en/stable/presets.html#tuning
      `,
    },
    {
      name: "Hardware Acceleration",
      type: "string",
      defaultValue: "",
      inputUI: {
        type: "dropdown",
        options: ["", "QuickSync"],
      },
      tooltip: `
      Specify hardware acceleration to use.
      Leave blank to use no hardware acceleration.\\n
      `,
    },
    {
      name: "10 Bit",
      type: "boolean",
      defaultValue: false,
      inputUI: {
        type: "dropdown",
        options: ["false", "true"],
      },
      tooltip: `
      Specify if output file should be forced to 10bit.\\n
      Default: false (bit depth is same as source).
      `,
    },
    {
      name: "CRF",
      type: "string",
      defaultValue: "28",
      inputUI: {
        type: "text",
      },
      tooltip: `
      Specify the CRF value you want to use.\\n
      Range: [0-51] (lower = higher quality, bigger file).\\n
      Default: 28
      Leave blank to use default.\\n
      https://x265.readthedocs.io/en/stable/cli.html#cmdoption-rc-lookahead
      For more info, see https://x265.readthedocs.io/en/stable/cli.html#cmdoption-crf
      `,
    },
    {
      name: "Downscale Resolution",
      type: "string",
      defaultValue: false,
      inputUI: {
        type: "dropdown",
        options: ["", "1080p", "720p", "480p"],
      },
      tooltip: `
      Specify if output file video resolution should be downscaled.\\n
      If video track is below the downscale resolution, no scaling will occur.\\n
      Leave blank to skip downscaling.\\n
      `,
    },
    {
      name: "Extra Video Filters",
      type: "string",
      defaultValue: "",
      inputUI: {
        type: "text",
      },
      tooltip: `
      Specify any extra video filters.\\n
      Leave blank to specify no extra video filter.\\n
      Comma separated.\\n
      `,
    },
    {
      name: "Downmix Audio",
      type: "boolean",
      defaultValue: false,
      inputUI: {
        type: "dropdown",
        options: ["false", "true"],
      },
      tooltip: `
      Specify if output file audio track should be downmixed to 2ch AAC.\\n
      Default: false.
      `,
    },
    {
      name: "bframes",
      type: "string",
      defaultValue: "",
      inputUI: {
        type: "text",
      },
      tooltip: `
      Specify number of b-frames to use.\\n
      Range: [0-16]\\n
      ${x265PresetOptionValuesString(3, 3, 4, 4, 4, 4, 4, 8, 8, 8)}
      Leave blank to use default.\\n
      For more info, see https://x265.readthedocs.io/en/stable/cli.html#cmdoption-bframes
      `,
    },
    {
      name: "bframe-bias",
      type: "string",
      defaultValue: "",
      inputUI: {
        type: "text",
      },
      tooltip: `
      Specify number of b-bias to use.\\n
      Range: [-90-100]\\n
      Default: 0\\n
      Leave blank to use default.\\n
      For more info, see https://x265.readthedocs.io/en/stable/cli.html#cmdoption-bframe-bias
      `,
    },
    {
      name: "b-adapt",
      type: "string",
      defaultValue: "",
      inputUI: {
        type: "text",
      },
      tooltip: `
      Specify  to use.\\n
      Range: [0-2]\\n
      ${x265PresetOptionValuesString(0, 0, 0, 0, 0, 2, 2, 2, 2, 2)}
      Leave blank to use default.\\n
      For more info, see https://x265.readthedocs.io/en/master/cli.html#cmdoption-
      `,
    },
    {
      name: "rc-lookahead",
      type: "string",
      defaultValue: "",
      inputUI: {
        type: "text",
      },
      tooltip: `
      Specify rc-lookahead to use.\\n
      Range: [bframes-250]\\n
      ${x265PresetOptionValuesString(5, 10, 15, 15, 15, 20, 25, 40, 40, 60)}
      Leave blank to use default.\\n
      For more info, see https://x265.readthedocs.io/en/stable/cli.html#cmdoption-rc-lookahead
      `,
    },
    {
      name: "lookahead-slices",
      type: "string",
      defaultValue: "",
      inputUI: {
        type: "text",
      },
      tooltip: `
      Specify lookahead-slices to use.\\n
      Range: [0-16]\\n
      ${x265PresetOptionValuesString(8, 8, 8, 8, 8, 8, 4, 1, 1, 1)}
      Leave blank to use default.\\n
      For more info, see https://x265.readthedocs.io/en/master/cli.html#cmdoption-lookahead-slices
      `,
    },
    {
      name: "ref",
      type: "string",
      defaultValue: "",
      inputUI: {
        type: "text",
      },
      tooltip: `
      Specify ref to use.\\n
      Range: [0-16]\\n
      ${x265PresetOptionValuesString(1, 1, 2, 2, 3, 3, 4, 5, 5, 5)}
      Leave blank to use default.\\n
      For more info, see https://x265.readthedocs.io/en/master/cli.html#cmdoption-ref
      `,
    },
    {
      name: "limit-refs",
      type: "string",
      defaultValue: "",
      inputUI: {
        type: "text",
      },
      tooltip: `
      Specify limit-refs to use.\\n
      Range: [0-3]\\n
      ${x265PresetOptionValuesString(0, 0, 3, 3, 3, 3, 3, 1, 0, 0)}
      Leave blank to use default.\\n
      For more info, see https://x265.readthedocs.io/en/master/cli.html#cmdoption-limit-refs
      `,
    },
    {
      name: "me",
      type: "string",
      defaultValue: "",
      inputUI: {
        type: "dropdown",
        options: ["", "dia", "hex", "umh", "star", "sea", "full"],
      },
      tooltip: `
      Specify me to use.\\n
      ${x265PresetOptionValuesString(
        "dia",
        "hex",
        "hex",
        "hex",
        "hex",
        "hex",
        "star",
        "star",
        "star",
        "star"
      )}
      Leave blank to use default.\\n
      For more info, see https://x265.readthedocs.io/en/master/cli.html#cmdoption-me
      `,
    },
    {
      name: "subme",
      type: "string",
      defaultValue: "",
      inputUI: {
        type: "text",
      },
      tooltip: `
      Specify subme to use.\\n
      Range: [0-7]\\n
      ${x265PresetOptionValuesString(0, 1, 1, 2, 2, 2, 3, 4, 4, 5)}
      Leave blank to use default.\\n
      For more info, see https://x265.readthedocs.io/en/master/cli.html#cmdoption-subme
      `,
    },
    {
      name: "rect",
      type: "string",
      defaultValue: "",
      inputUI: {
        type: "dropdown",
        options: ["", "false", "true"],
      },
      tooltip: `
      Specify if rect should be used.\\n
      ${x265PresetOptionValuesString(
        false,
        false,
        false,
        false,
        false,
        false,
        true,
        true,
        true,
        true
      )}
      Leave blank to use default.\\n
      For more info, see https://x265.readthedocs.io/en/master/cli.html#cmdoption-rect
      `,
    },
    {
      name: "amp",
      type: "string",
      defaultValue: "",
      inputUI: {
        type: "dropdown",
        options: ["", "false", "true"],
      },
      tooltip: `
      Specify if amp should be used.\\n
      ${x265PresetOptionValuesString(
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        true,
        true,
        true
      )}
      Leave blank to use default.\\n
      For more info, see https://x265.readthedocs.io/en/master/cli.html#cmdoption-amp
      `,
    },
    {
      name: "limit-modes",
      type: "string",
      defaultValue: "",
      inputUI: {
        type: "dropdown",
        options: ["", "false", "true"],
      },
      tooltip: `
      Specify if limit-modes should be used.\\n
      ${x265PresetOptionValuesString(
        false,
        false,
        false,
        false,
        false,
        false,
        true,
        true,
        false,
        false
      )}
      Leave blank to use default.\\n
      For more info, see https://x265.readthedocs.io/en/master/cli.html#cmdoption-limit-modes
      `,
    },
    {
      name: "max-merge",
      type: "string",
      defaultValue: "",
      inputUI: {
        type: "text",
      },
      tooltip: `
      Specify max-merge to use.\\n
      ${x265PresetOptionValuesString(2, 2, 2, 2, 2, 2, 3, 4, 5, 5)}
      Leave blank to use default.\\n
      For more info, see https://x265.readthedocs.io/en/master/cli.html#cmdoption-max-merge
      `,
    },
    {
      name: "early-skip",
      type: "string",
      defaultValue: "",
      inputUI: {
        type: "dropdown",
        options: ["", "false", "true"],
      },
      tooltip: `
      Specify if early-skip should be used.\\n
      ${x265PresetOptionValuesString(
        true,
        true,
        true,
        true,
        false,
        true,
        false,
        false,
        false,
        false
      )}
      Leave blank to use default.\\n
      For more info, see https://x265.readthedocs.io/en/master/cli.html#cmdoption-early-skip
      `,
    },
    {
      name: "rskip",
      type: "string",
      defaultValue: "",
      inputUI: {
        type: "text",
      },
      tooltip: `
      Specify rskip to use.\\n
      Range: [0-2]\\n
      ${x265PresetOptionValuesString(1, 1, 1, 1, 1, 1, 1, 1, 1, 0)}
      Leave blank to use default.\\n
      For more info, see https://x265.readthedocs.io/en/master/cli.html#cmdoption-rskip
      `,
    },
    {
      name: "fast-intra",
      type: "string",
      defaultValue: "",
      inputUI: {
        type: "dropdown",
        options: ["", "false", "true"],
      },
      tooltip: `
      Specify if fast-intra should be used.\\n
      ${x265PresetOptionValuesString(
        true,
        true,
        true,
        true,
        true,
        false,
        false,
        false,
        false,
        false
      )}
      Leave blank to use default.\\n
      For more info, see https://x265.readthedocs.io/en/master/cli.html#cmdoption-fast-intra
      `,
    },
    {
      name: "b-intra",
      type: "string",
      defaultValue: "",
      inputUI: {
        type: "dropdown",
        options: ["", "false", "true"],
      },
      tooltip: `
      Specify if b-intra should be used.\\n
      ${x265PresetOptionValuesString(
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        true,
        true,
        true
      )}
      Leave blank to use default.\\n
      For more info, see https://x265.readthedocs.io/en/master/cli.html#cmdoption-b-intra
      `,
    },
    {
      name: "sao",
      type: "string",
      defaultValue: "",
      inputUI: {
        type: "dropdown",
        options: ["", "false", "true"],
      },
      tooltip: `
      Specify if sao should be used.\\n
      ${x265PresetOptionValuesString(
        false,
        false,
        true,
        true,
        true,
        true,
        true,
        true,
        true,
        true
      )}
      Leave blank to use default.\\n
      For more info, see https://x265.readthedocs.io/en/master/cli.html#cmdoption-sao
      `,
    },
    {
      name: "weightp",
      type: "string",
      defaultValue: "",
      inputUI: {
        type: "dropdown",
        options: ["", "false", "true"],
      },
      tooltip: `
      Specify if weightp should be used.\\n
      ${x265PresetOptionValuesString(
        false,
        false,
        true,
        true,
        true,
        true,
        true,
        true,
        true,
        true
      )}
      Leave blank to use default.\\n
      For more info, see https://x265.readthedocs.io/en/master/cli.html#cmdoption-weightp
      `,
    },
    {
      name: "weightb",
      type: "string",
      defaultValue: "",
      inputUI: {
        type: "dropdown",
        options: ["", "false", "true"],
      },
      tooltip: `
      Specify if weightb should be used.\\n
      ${x265PresetOptionValuesString(
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        true,
        true,
        true
      )}
      Leave blank to use default.\\n
      For more info, see https://x265.readthedocs.io/en/master/cli.html#cmdoption-weightb
      `,
    },
    {
      name: "aq-mode",
      type: "string",
      defaultValue: "",
      inputUI: {
        type: "text",
      },
      tooltip: `
      Specify aq-mode to use.\\n
      Range: [0-4]\\n
      ${x265PresetOptionValuesString(0, 0, 2, 2, 2, 2, 2, 2, 2, 2)}
      Leave blank to use default.\\n
      For more info, see https://x265.readthedocs.io/en/stable/cli.html#cmdoption-aq-mode
      `,
    },
    {
      name: "rd",
      type: "string",
      defaultValue: "",
      inputUI: {
        type: "text",
      },
      tooltip: `
      Specify rd to use.\\n
      Range: [0-6]\\n
      ${x265PresetOptionValuesString(2, 2, 2, 2, 2, 3, 4, 6, 6, 6)}
      Leave blank to use default.\\n
      For more info, see https://x265.readthedocs.io/en/stable/cli.html#cmdoption-rd
      `,
    },
    {
      name: "rdoq-level",
      type: "string",
      defaultValue: "",
      inputUI: {
        type: "text",
      },
      tooltip: `
      Specify rdoq-level to use.\\n
      Range: [0-2]\\n
      ${x265PresetOptionValuesString(0, 0, 0, 0, 0, 0, 2, 2, 2, 2)}
      Leave blank to use default.\\n
      For more info, see https://x265.readthedocs.io/en/stable/cli.html#cmdoption-rdoq-level
      `,
    },
    {
      name: "tu-intra-depth",
      type: "string",
      defaultValue: "",
      inputUI: {
        type: "text",
      },
      tooltip: `
      Specify tu-intra-depth to use.\\n
      Range: [1-4]\\n
      ${x265PresetOptionValuesString(1, 1, 1, 1, 1, 1, 1, 3, 3, 4)}
      Leave blank to use default.\\n
      For more info, see https://x265.readthedocs.io/en/stable/cli.html#cmdoption-tu-intra-depth
      `,
    },
    {
      name: "tu-inter-depth",
      type: "string",
      defaultValue: "",
      inputUI: {
        type: "text",
      },
      tooltip: `
      Specify tu-inter-depth to use.\\n
      Range: [1-4]\\n
      ${x265PresetOptionValuesString(1, 1, 1, 1, 1, 1, 1, 3, 3, 4)}
      Leave blank to use default.\\n
      For more info, see https://x265.readthedocs.io/en/stable/cli.html#cmdoption-tu-inter-depth
      `,
    },
    {
      name: "limit-tu",
      type: "string",
      defaultValue: "",
      inputUI: {
        type: "text",
      },
      tooltip: `
      Specify limit-tu to use.\\n
      Range: [0-4]\\n
      ${x265PresetOptionValuesString(0, 0, 0, 0, 0, 0, 0, 4, 0, 0)}
      Leave blank to use default.\\n
      For more info, see https://x265.readthedocs.io/en/stable/cli.html#cmdoption-limit-tu
      `,
    },
    {
      name: "Extra x265 Args",
      type: "string",
      defaultValue:
        "--range limited --colorprim bt709 --transfer bt709 --colormatrix bt709",
      inputUI: {
        type: "text",
      },
      tooltip: `
      Specify any extra x265 arguments.\\n
      Leave blank to specify no extra x265 arguments.\\n
      Use the x265 CLI argument format found in the x265 documentation.\\n
      For all arguments, see https://x265.readthedocs.io/en/stable/cli.html\\n
      Example:\\n
      --deblock -1:-1 --range limited --colorprim bt709 --transfer bt709 --colormatrix bt709
      `,
    },
  ],
});

// eslint-disable-next-line no-unused-vars
const plugin = (file, librarySettings, inputs, otherArguments) => {
  const lib = require("../methods/lib")();

  // Load and check plugin inputs
  inputs = lib.loadDefaultValues(inputs, details);

  // Create response object
  const response = {
    processFile: false,
    preset: "",
    container: ".mkv",
    handBrakeMode: false,
    FFmpegMode: true,
    reQueueAfter: true,
    infoLog: "",
  };

  // Check if the file is a video, if not the plugin will exit
  if (file.fileMedium !== "video") {
    response.infoLog += "☒ File is not a video\n";
    return response;
  }
  response.infoLog += "☑ File is a video\n";

  // Check if the video has a HEVC track, if not the plugin will exit
  if (
    file.ffProbeData.streams.some((x) => x.codec_name?.toLowerCase() === "hevc")
  ) {
    response.infoLog += "☑ File is already HEVC! Will not transcode\n";
    return response;
  }

  // if we made it to this point it is safe to assume there is no hevc stream
  response.infoLog += "☒ File is not HEVC! Will transcode\n";

  // Get inputs
  const preset = inputs["Preset"];
  const tuning = inputs["Tuning"];
  const hwaccel = inputs["Hardware Acceleration"];
  const use10Bit = inputs["10 Bit"];
  const crf = inputs["CRF"];
  const downscaleResolution = inputs["Downscale Resolution"];
  // const downscaleAlgorithm = "lanczos";
  const downscaleAlgorithm = "spline36";
  const downmix = inputs["Downmix Audio"];

  // Decoding arguments
  // https://ffmpeg.org/ffmpeg.html
  const decodingArgs = [];

  // Encoding arguments
  // https://ffmpeg.org/ffmpeg.html
  const encodingArgs = [
    // Map ALL streams from the input file to output file
    "-map 0",
    // Copy subtitle streams
    "-c:s copy",
  ];

  // Set video codec and hardware acceleration tyoe (is using)
  let videoCodec = "libx265";
  if (hwaccel) {
    let hwaccelType;
    if (hwaccel.toLowerCase() == "quicksync") {
      // See https://trac.ffmpeg.org/wiki/Hardware/QuickSync
      response.infoLog += `☑ Using QuickSync Hardware Acceleration\n`;
      hwaccelType = "qsv";
      videoCodec = "hevc_qsv";
    }
    decodingArgs.push(`-hwaccel ${hwaccelType}`);
    // decodingArgs.push(`-c:v ${videoCodec}`);
  }
  encodingArgs.push(`-c:v ${videoCodec}`);

  // 10 bit
  if (use10Bit) {
    response.infoLog += "☑ Encoding as 10bit\n";
    encodingArgs.push("-pix_fmt yuv420p10le");
    encodingArgs.push("-profile:v main10"); // https://x265.readthedocs.io/en/stable/cli.html#cmdoption-profile
  } else {
    response.infoLog += "☒ Keeping source bit depth\n";
  }

  // Set preset
  // https://x265.readthedocs.io/en/stable/presets.html
  response.infoLog += `☑ Preset set to ${preset}\n`;
  encodingArgs.push(`-preset:v ${preset}`);

  // Tuning
  // https://x265.readthedocs.io/en/stable/presets.html#tuning
  if (tuning !== "") {
    response.infoLog += `☑ ${tuning} tuning option set\n`;
    encodingArgs.push(`-tune ${tuning}`);
  } else {
    response.infoLog += `☒ No tuning option set\n`;
  }

  // CRF
  // https://x265.readthedocs.io/en/master/cli.html#cmdoption-crf
  if (crf !== "") {
    response.infoLog += `☑ CRF set to ${crf}\n`;
    encodingArgs.push(`-crf:v ${crf}`);
  } else {
    response.infoLog += `☒ Using default CRF of 28\n`;
  }

  // Get ffmpeg video filters
  const videoFilters = [];

  // Downscaling filter
  let scaleWidth;
  if (downscaleResolution === "1080p" && file.meta.ImageWidth > 1920) {
    response.infoLog += `☑ Downscaling video resolution to 1080p\n`;
    scaleWidth = "1920";
  } else if (downscaleResolution === "720p" && file.meta.ImageWidth > 1280) {
    response.infoLog += `☑ Downscaling video resolution to 720p\n`;
    scaleWidth = "1280";
  } else if (downscaleResolution === "480p" && file.meta.ImageWidth > 720) {
    response.infoLog += `☑ Downscaling video resolution to 480p\n`;
    scaleWidth = "720";
  } else {
    response.infoLog += `☒ Skipping video downscaling\n`;
  }

  if (scaleWidth) {
    videoFilters.push(`zscale=${scaleWidth}:-1:filter=${downscaleAlgorithm}`);
  }

  // Extra video filters
  const extraVideoFilters = inputs["Extra Video Filters"];
  let extraVideoFiltersParams = stringToFFmpegParams(extraVideoFilters, ",");
  if (extraVideoFiltersParams.length !== 0) {
    response.infoLog += `☑ Extra video filters:\n  ${extraVideoFiltersParams.join(
      "\n  "
    )}\n`;
    videoFilters.push(...extraVideoFiltersParams);
  }

  // Add video filters (if there are any) to encoding args
  if (videoFilters.length !== 0) {
    encodingArgs.push(`-vf "${videoFilters.join(",")}"`);
  }

  // Downmix audio
  let audioIdx = 0;
  for (let i = 0; i < file.ffProbeData.streams.length; i++) {
    const stream = file.ffProbeData.streams[i];

    // If stream is not an audio stream, skip
    if (stream.codec_type.toLowerCase() !== "audio") {
      continue;
    }

    // Get info about audio stream
    const numChannels = file.ffProbeData.streams[i].channels;
    const audioCodec = file.ffProbeData.streams[i].codec_name;

    if (numChannels > 2 && downmix) {
      response.infoLog += `☑ Audio track ${audioIdx} is not 2ch. Downmixing.\n`;
      encodingArgs.push(
        ...[
          `-c:a:${audioIdx} aac`, // Encode audio stream as AAC
          "-ac 2", // Set number of audio channels to 2
          `-metadata:s:a:${audioIdx} title="2.0"`, // Add audio stream metadata
        ]
      );
    } else if (numChannels === 2 && audioCodec !== "aac") {
      response.infoLog += `☑ Audio track ${audioIdx} is 2ch but not AAC. Converting.\n`;
      encodingArgs.push(`-c:a:${audioIdx} aac`); // Encode audio stream as AAC
    } else {
      response.infoLog += `☑ Audio track ${audioIdx} is 2ch and AAC. Copying.\n`;
      encodingArgs.push(`-c:a:${audioIdx} copy`); // Copy (don't re-encode) audio stream
    }

    // Increment audio stream index
    audioIdx += 1;
  }

  // Get ffmpeg x265 parameters
  // https://x265.readthedocs.io/en/stable/cli.html
  const x265Params = [];
  for (const optionName of x265PresetOptions) {
    let optionValue = inputs[optionName];
    addOptionToX265Params(x265Params, response, optionName, optionValue);
  }

  // Add extra x265 args
  const extraX265Args = inputs["Extra x265 Args"];
  let extraX265Params = x265ArgsToParams(extraX265Args);
  if (extraX265Params.length !== 0) {
    response.infoLog += `☑ Extra x265 args:\n  ${extraX265Params.join(
      "\n  "
    )}\n`;
    x265Params.push(...extraX265Params);
  }

  // FFMpeg args
  const ffmpegArgs = [];
  ffmpegArgs.push(...decodingArgs);
  ffmpegArgs.push("<io>");
  ffmpegArgs.push(...encodingArgs);

  // Add x265 params (if there are any) to ffmp args
  if (x265Params.length !== 0) {
    ffmpegArgs.push(`-x265-params "${x265Params.join(":")}"`);
  }

  // Update response object
  response.infoLog += "File is being transcoded\n";
  response.processFile = true;
  response.preset = ffmpegArgs.join(" ");

  return response;
};

// Create list of the options specified in presets
// See https://x265.readthedocs.io/en/stable/presets.html#presets
const x265PresetOptions = [
  "bframes",
  "bframe-bias",
  "b-adapt",
  "rc-lookahead",
  "lookahead-slices",
  "ref",
  "limit-refs",
  "me",
  "subme",
  "rect",
  "amp",
  "limit-modes",
  "max-merge",
  "early-skip",
  "rskip",
  "fast-intra",
  "b-intra",
  "sao",
  "weightp",
  "weightb",
  "aq-mode",
  "rd",
  "rdoq-level",
  "tu-intra-depth",
  "tu-inter-depth",
  "limit-tu",
];

function x265PresetOptionValuesString(
  ultrafastValue,
  superfastValue,
  veryfastValue,
  fasterValue,
  fastValue,
  mediumValue,
  slowValue,
  slowerValue,
  veryslowValue,
  placeboValue
) {
  return `Defaults:
  - ultrafast: ${ultrafastValue}\\n
  - superfast: ${superfastValue}\\n
  - veryfast:  ${veryfastValue}\\n
  - faster:    ${fasterValue}\\n
  - fast:      ${fastValue}\\n
  - medium:    ${mediumValue}\\n
  - slow:      ${slowValue}\\n
  - slower:    ${slowerValue}\\n
  - veryslow:  ${veryslowValue}\\n
  - placebo:   ${placeboValue}\\n`;
}

function addOptionToX265Params(x265Params, response, optionName, optionValue) {
  // If option is set, add to x265 parameters
  if (optionValue !== "") {
    response.infoLog += `☑ ${optionName} set to ${optionValue}\n`;

    // Change option value to a integer if it is a boolean string
    if (optionValue === "true") {
      optionValue = 1;
    } else if (optionValue === "false") {
      optionValue = 0;
    }

    // Add a option as a parameter to the x265 parameters
    x265Params.push(`${optionName}=${optionValue}`);
  }
}

function stringToFFmpegParams(optionsString, separator) {
  return optionsString
    .trim()
    .replace(new RegExp(`\\s*${separator}\\s*`, "g"), separator) // Fix separators
    .replace(/=/g, " ")
    .replace(/\s+(?=([^"]*"[^"]*")*[^"]*$)/g, "=") // Replace spaces, except inbetween quotes, with =
    .replace(/"/g, "")
    .split(separator)
    .filter((ffmpegParam) => ffmpegParam !== "");
}

function x265ArgsToParams(x265ArgsString) {
  let ffmpegParams = stringToFFmpegParams(x265ArgsString, "--");
  for (let i = 0; i < ffmpegParams.length; i++) {
    let ffmpegParamPair = ffmpegParams[i].split("=");
    if (ffmpegParamPair.length === 1) {
      if (ffmpegParamPair[0].startsWith("no-")) {
        ffmpegParamPair[0] = ffmpegParamPair[0].slice(3);
        ffmpegParamPair.push(0);
      } else {
        ffmpegParamPair.push(1);
      }
      ffmpegParams[i] = ffmpegParamPair.join("=");
    }
  }
  return ffmpegParams;
}

module.exports.details = details;
module.exports.plugin = plugin;
