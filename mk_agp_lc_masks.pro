FUNCTION mk_agp_lc_masks, $
   misr_path, $
   misr_block, $
   misr_resol, $
   landcover, $
   agp_masks, $
   AGP_FOLDER = agp_folder, $
   AGP_VERSION = agp_version, $
   LOG_IT = log_it, $
   LOG_FOLDER = log_folder, $
   MAP_IT = map_it, $
   MAP_FOLDER = map_folder, $
   VERBOSE = verbose, $
   DEBUG = debug, $
   EXCPT_COND = excpt_cond

   ;Sec-Doc
   ;  PURPOSE: This function sets the output positional parameter
   ;  landcover to a single 2D array containing the land cover
   ;  classification (7 classes) based on the information available in the
   ;  AGP file for the specified MISR PATH and BLOCK, and the output
   ;  positional parameter agp_masks to an array of 7 landcover masks, one
   ;  per defined class.
   ;
   ;  ALGORITHM: This function retrieves the basic landcover
   ;  classification for the specified PATH and BLOCK from the relevant
   ;  MISR AGP file and generates 7 individual binary masks, one for each
   ;  recognized class, at the specified spatial resolution (either 275 or
   ;  1100 m), as well as an overall array containing all classes.
   ;  Within each individual land cover class mask, each pixel is assigned
   ;  the value 0B if that location does not belong to that class, or 1B
   ;  if it does. A log file is generated if the optional keyword
   ;  parameter LOG_IT is specified, and each of the 8 masks is also saved
   ;  as a map if the optional keyword parameter MAP_IT is set. In that
   ;  case, the land cover classes are assigned the following colors:
   ;
   ;  *   landcover code 0: Shallow ocean, blue.
   ;
   ;  *   landcover code 1: Land, green.
   ;
   ;  *   landcover code 2: Coastline, tan.
   ;
   ;  *   landcover code 3: Shallow inland water, cyan.
   ;
   ;  *   landcover code 4: Ephemeral water, turquoise.
   ;
   ;  *   landcover code 5: Deep inland water, purple.
   ;
   ;  *   landcover code 6: Deep ocean, navy.
   ;
   ;  The masks are generated at the original low spatial resolution
   ;  (1100 m) of the MISR AGP file, and upscaled to the higher spatial
   ;  resolution (275 m) if requested, using the function lr2hr.pro.
   ;
   ;  SYNTAX: rc = mk_agp_lc_masks(misr_path, misr_block, misr_resol, $
   ;  landcover, agp_masks, $
   ;  AGP_FOLDER = agp_folder, AGP_VERSION = agp_version, $
   ;  LOG_IT = log_it, LOG_FOLDER = log_folder, $
   ;  MAP_IT = map_it, MAP_FOLDER = map_folder$
   ;  VERBOSE = verbose, DEBUG = debug, EXCPT_COND = excpt_cond)
   ;
   ;  POSITIONAL PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   misr_path {INT} [I]: The specified MISR PATH number.
   ;
   ;  *   misr_block {INT} [I]: The specified initial MISR BLOCK number.
   ;
   ;  *   misr_resol {INT} [I]: The required spatial resolution of the
   ;      output mask: either 275 or 1100 (in m).
   ;
   ;  *   landcover {BYTE array} [O]: The landcover information contained
   ;      in the MISR AGP file for the specified PATH and BLOCK.
   ;
   ;  *   agp_masks {BYTE array} [O]: The array of 7 binary masks, one per
   ;      landcover class, for the specified PATH and BLOCK.
   ;
   ;  KEYWORD PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   AGP_FOLDER = agp_folder {STRING} [I] (Default value: Set by
   ;      function
   ;      set_roots_vers.pro): The directory address of the folder
   ;      containing the MISR AGP files, if they are not located in the
   ;      default location.
   ;
   ;  *   AGP_VERSION = agp_version {STRING} [I] (Default value: Set by
   ;      function
   ;      set_roots_vers.pro): The AGP version identifier to use instead
   ;      of the default value.
   ;
   ;  *   LOG_IT = log_it {INT} [I] (Default value: 0): Flag to activate
   ;      (1) or skip (0) generating a log file.
   ;
   ;  *   LOG_FOLDER = log_folder {STRING} [I] (Default value: Set by
   ;      function
   ;      set_roots_vers.pro): The directory address of the output folder
   ;      containing the processing log.
   ;
   ;  *   MAP_IT = map_it {INT} [I] (Default value: 0): Flag to activate
   ;      (1) or skip (0) generating maps of the numerical results.
   ;
   ;  *   MAP_FOLDER = map_folder {STRING} [I] (Default value: Set by
   ;      function
   ;      set_roots_vers.pro): The directory address of the output folder
   ;      containing the maps.
   ;
   ;  *   VERBOSE = verbose {INT} [I] (Default value: 0): Flag to enable
   ;      (> 0) or skip (0) outputting messages on the console:
   ;
   ;      -   If verbose > 0, messages inform the user about progress in
   ;          the execution of time-consuming routines, or the location of
   ;          output files (e.g., log, map, plot, etc.);
   ;
   ;      -   If verbose > 1, messages record entering and exiting the
   ;          routine; and
   ;
   ;      -   If verbose > 2, messages provide additional information
   ;          about intermediary results.
   ;
   ;  *   DEBUG = debug {INT} [I] (Default value: 0): Flag to activate (1)
   ;      or skip (0) debugging tests.
   ;
   ;  *   EXCPT_COND = excpt_cond {STRING} [O] (Default value: ”):
   ;      Description of the exception condition if one has been
   ;      encountered, or a null string otherwise.
   ;
   ;  RETURNED VALUE TYPE: INT.
   ;
   ;  OUTCOME:
   ;
   ;  *   If no exception condition has been detected, this function
   ;      returns 0, and the output keyword parameter excpt_cond is set to
   ;      a null string, if the optional input keyword parameter DEBUG is
   ;      set and if the optional output keyword parameter EXCPT_COND is
   ;      provided in the call. The landcover and the array of binary
   ;      masks are returned as output positional parameter; a log file is
   ;      created and saved if the input keyword parameter LOG_IT is set,
   ;      and maps of the landcover and of these masks are generated and
   ;      saved if the input keyword parameter MAP_IT is set in the call.
   ;
   ;  *   If an exception condition has been detected, this function
   ;      returns a non-zero error code, and the output keyword parameter
   ;      excpt_cond contains a message about the exception condition
   ;      encountered, if the optional input keyword parameter DEBUG is
   ;      set and if the optional output keyword parameter EXCPT_COND is
   ;      provided in the call. The landcover and the array of binary
   ;      masks may be inexistent, incomplete or incorrect.
   ;
   ;  EXCEPTION CONDITIONS:
   ;
   ;  *   Warning 98: The computer has not been recognized by the function
   ;      get_host_info.pro.
   ;
   ;  *   Error 100: One or more positional parameter(s) are missing.
   ;
   ;  *   Error 110: The input positional parameter misr_path is invalid.
   ;
   ;  *   Error 120: The input positional parameters misr_block is
   ;      invalid.
   ;
   ;  *   Error 130: The input positional parameters misr_resol is
   ;      invalid.
   ;
   ;  *   Error 199: An exception condition occurred in
   ;      set_roots_vers.pro.
   ;
   ;  *   Error 200: An exception condition occurred in path2str.pro.
   ;
   ;  *   Error 210: An exception condition occurred in block2str.pro.
   ;
   ;  *   Error 220: An exception condition occurred in find_agp_file.pro.
   ;
   ;  *   Error 299: The function set_roots_vers.pro could not assign
   ;      values to the array root_dirs and one or more directory
   ;      addresses agp_folder, log_folder and map_folder have not been
   ;      specified through input keyword parameters.
   ;
   ;  *   Error 400: The output folder log_fpath is unwritable.
   ;
   ;  *   Error 410: The output folder map_fpath is unwritable.
   ;
   ;  *   Error 500: An exception condition occurred in lr2hr.pro.
   ;
   ;  *   Error 510: An exception condition occurred in make_bytemap.pro
   ;      while generating the overall map (all classes).
   ;
   ;  *   Error 520: An exception condition occurred in make_bytemap.pro
   ;      while generating the Shallow ocean map.
   ;
   ;  *   Error 530: An exception condition occurred in make_bytemap.pro
   ;      while generating the Landcover map.
   ;
   ;  *   Error 540: An exception condition occurred in make_bytemap.pro
   ;      while generating the Coastline map.
   ;
   ;  *   Error 550: An exception condition occurred in make_bytemap.pro
   ;      while generating the Shallow inland water map.
   ;
   ;  *   Error 560: An exception condition occurred in make_bytemap.pro
   ;      while generating the Ephemeral water map.
   ;
   ;  *   Error 570: An exception condition occurred in make_bytemap.pro
   ;      while generating the Deep inland water map.
   ;
   ;  *   Error 580: An exception condition occurred in make_bytemap.pro
   ;      while generating the Deep ocean map.
   ;
   ;  *   Error 600: An exception condition occurred in the MISR TOOLKIT
   ;      routine
   ;      MTK_SETREGION_BY_PATH_BLOCKRANGE.
   ;
   ;  *   Error 610: An exception condition occurred in the MISR TOOLKIT
   ;      routine
   ;      MTK_READDATA.
   ;
   ;  DEPENDENCIES:
   ;
   ;  *   MISR Toolkit
   ;
   ;  *   block2str.pro
   ;
   ;  *   chk_misr_block.pro
   ;
   ;  *   chk_misr_path.pro
   ;
   ;  *   chk_misr_resol.pro
   ;
   ;  *   force_path_sep.pro
   ;
   ;  *   find_agp_file.pro
   ;
   ;  *   is_numeric.pro
   ;
   ;  *   is_writable_dir.pro
   ;
   ;  *   lr2hr.pro
   ;
   ;  *   make_bytemap.pro
   ;
   ;  *   path2str.pro
   ;
   ;  *   set_roots_vers.pro
   ;
   ;  *   strstr.pro
   ;
   ;  *   today.pro
   ;
   ;  REMARKS:
   ;
   ;  *   NOTE 1: Land cover information is provided by the MISR AGP file
   ;      everywhere: there is no concept of fill values in this context.
   ;
   ;  *   NOTE 2: Setting the misr_resol input positional parameter to 275
   ;      generates a set of ‘high-resolution’ land cover masks by
   ;      duplicating the low-resolution information contained in the MISR
   ;      AGP file: it does not provide more detailed information than
   ;      what is available in that source file.
   ;
   ;  EXAMPLES:
   ;
   ;      IDL> misr_path = 168
   ;      IDL> misr_block = 112
   ;      IDL> misr_resol = 1100
   ;      IDL> AGP_FOLDER = ''
   ;      IDL> AGP_VERSION = ''
   ;      IDL> LOG_IT = 1
   ;      IDL> LOG_FOLDER = ''
   ;      IDL> MAP_IT = 1
   ;      IDL> MAP_FOLDER = ''
   ;      IDL> DEBUG = 1
   ;      IDL> c = mk_agp_lc_masks(misr_path, misr_block, misr_resol, $
   ;         landcover, agp_masks, $
   ;         AGP_FOLDER = agp_folder, AGP_VERSION = agp_version, $
   ;         LOG_IT = log_it, LOG_FOLDER = log_folder, $
   ;         MAP_IT = map_it, MAP_FOLDER = map_folder, $
   ;         DEBUG = debug, EXCPT_COND = excpt_cond)
   ;      IDL> rc = mk_agp_lc_masks(misr_path, misr_block, misr_resol, $
   ;         landcover, agp_masks, $
   ;         AGP_FOLDER = agp_folder, AGP_VERSION = agp_version, $
   ;         LOG_IT = log_it, LOG_FOLDER = log_folder, $
   ;         MAP_IT = map_it, MAP_FOLDER = map_folder, $
   ;         DEBUG = debug, EXCPT_COND = excpt_cond)
   ;      IDL> IF (rc EQ 0) THEN PRINT, 'Processing nominal.' $
   ;         ELSE PRINT, 'excpt_cond = >' + excpt_cond + '<'
   ;      Processing nominal.
   ;
   ;  REFERENCES:
   ;
   ;  *   Mike Bull, Jason Matthews, Duncan McDonald, Alexander Menzies,
   ;      Catherine Moroney, Kevin Mueller, Susan Paradise, Mike
   ;      Smyth (2011) _MISR Data Products Specifications_, JPL D-13963,
   ;      REVISION S, Section 9.4, p. 210, Jet Propulsion Laboratory,
   ;      California Institute of Technology, Pasadena, CA, USA.
   ;
   ;  VERSIONING:
   ;
   ;  *   2018–05–13: Version 0.9 — Initial release, under the name
   ;      make_agp_lc_masks.pro.
   ;
   ;  *   2018–05–15: Version 1.0 — Initial public release.
   ;
   ;  *   2018–05–18: Version 1.5 — Implement new coding standards.
   ;
   ;  *   2018–08–02: Version 1.6 — Update documentation.
   ;
   ;  *   2018–12–17: Version 1.7 — Update the code to use
   ;      set_roots_vers.pro and
   ;      make_bytemap.pro.
   ;
   ;  *   2019–01–07: Version 1.8 — Rename this function from
   ;      make_agp_lc_masks.pro to mk_agp_lc_masks.pro and update the
   ;      documentation.
   ;
   ;  *   2019–01–28: Version 2.00 — Systematic update of all routines to
   ;      implement stricter coding standards and improve documentation.
   ;
   ;  *   2019–02–24: Version 2.01 — Documentation update.
   ;
   ;  *   2019–05–04: Version 2.02 — Update the code to report the
   ;      specific error message of MTK routines.
   ;
   ;  *   2019–08–20: Version 2.1.0 — Adopt revised coding and
   ;      documentation standards (in particular regarding the use of
   ;      verbose and the assignment of numeric return codes), and switch
   ;      to 3-parts version identifiers.
   ;Sec-Lic
   ;  INTELLECTUAL PROPERTY RIGHTS
   ;
   ;  *   Copyright (C) 2017-2020 Michel M. Verstraete.
   ;
   ;      Permission is hereby granted, free of charge, to any person
   ;      obtaining a copy of this software and associated documentation
   ;      files (the “Software”), to deal in the Software without
   ;      restriction, including without limitation the rights to use,
   ;      copy, modify, merge, publish, distribute, sublicense, and/or
   ;      sell copies of the Software, and to permit persons to whom the
   ;      Software is furnished to do so, subject to the following three
   ;      conditions:
   ;
   ;      1. The above copyright notice and this permission notice shall
   ;      be included in their entirety in all copies or substantial
   ;      portions of the Software.
   ;
   ;      2. THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY
   ;      KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
   ;      WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
   ;      AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
   ;      HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
   ;      WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
   ;      FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
   ;      OTHER DEALINGS IN THE SOFTWARE.
   ;
   ;      See: https://opensource.org/licenses/MIT.
   ;
   ;      3. The current version of this Software is freely available from
   ;
   ;      https://github.com/mmverstraete.
   ;
   ;  *   Feedback
   ;
   ;      Please send comments and suggestions to the author at
   ;      MMVerstraete@gmail.com
   ;Sec-Cod

   COMPILE_OPT idl2, HIDDEN

   ;  Get the name of this routine:
   info = SCOPE_TRACEBACK(/STRUCTURE)
   rout_name = info[N_ELEMENTS(info) - 1].ROUTINE

   ;  Initialize the default return code:
   return_code = 0

   ;  Set the default values of flags and essential output keyword parameters:
   IF (KEYWORD_SET(log_it)) THEN log_it = 1 ELSE log_it = 0
   IF (KEYWORD_SET(map_it)) THEN map_it = 1 ELSE map_it = 0
   IF (KEYWORD_SET(verbose)) THEN BEGIN
      IF (is_numeric(verbose)) THEN verbose = FIX(verbose) ELSE verbose = 0
      IF (verbose LT 0) THEN verbose = 0
      IF (verbose GT 3) THEN verbose = 3
   ENDIF ELSE verbose = 0
   IF (KEYWORD_SET(debug)) THEN debug = 1 ELSE debug = 0
   excpt_cond = ''

   IF (verbose GT 1) THEN PRINT, 'Entering ' + rout_name + '.'

   IF (debug) THEN BEGIN

   ;  Return to the calling routine with an error message if one or more
   ;  positional parameters are missing:
      n_reqs = 5
      IF (N_PARAMS() NE n_reqs) THEN BEGIN
         error_code = 100
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Routine must be called with ' + strstr(n_reqs) + $
            ' positional parameter(s): misr_path, misr_block, ' + $
            'misr_resol, landcover, agp_masks.'
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if the input
   ;  positional parameter 'misr_path' is invalid:
      rc = chk_misr_path(misr_path, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         error_code = 110
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if the input
   ;  positional parameter 'misr_block' is invalid:
      rc = chk_misr_block(misr_block, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         error_code = 120
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if the input spatial
   ;  resolution 'misr_resol' is invalid:
      rc = chk_misr_resol(misr_resol, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         error_code = 130
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF
   ENDIF

   ;  Identify the current operating system and computer name:
   rc = get_host_info(os_name, comp_name, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (rc NE 0) THEN BEGIN
      error_code = 98
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      PRINT, excpt_cond
   ENDIF

   ;  Set the default folders and version identifiers of the MISR and
   ;  MISR-HR files on this computer, and return to the calling routine if
   ;  there is an internal error, but not if the computer is unrecognized, as
   ;  root addresses can be overridden by input keyword parameters:
   rc_roots = set_roots_vers(root_dirs, versions, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (debug AND (rc_roots GE 100)) THEN BEGIN
      error_code = 199
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  Set the MISR and MISR-HR version numbers if they have not been specified
   ;  explicitly:
   IF (~KEYWORD_SET(agp_version)) THEN agp_version = versions[0]

   ;  Get today's date:
   date = today(FMT = 'ymd')

   ;  Get today's date and time:
   date_time = today(FMT = 'nice')

   ;  Generate the long string version of the MISR Path number:
   rc = path2str(misr_path, misr_path_str, DEBUG = debug, $
      EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 200
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  Generate the long string version of the MISR Block number:
   rc = block2str(misr_block, misr_block_str, DEBUG = debug, $
      EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 210
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF
   pb_str_u = strcat([misr_path_str, misr_block_str], '_')
   pb_str_d = strcat([misr_path_str, misr_block_str], '-')

   ;  Return to the calling routine with an error message if the routine
   ;  set_roots_vers.pro could not assign valid values to the array root_dirs
   ;  and the required MISR and MISR-HR root folders have not been initialized:
   IF (debug AND (rc_roots EQ 99)) THEN BEGIN
      IF (~KEYWORD_SET(agp_folder) OR $
         (log_it AND (~KEYWORD_SET(log_folder))) OR $
         (map_it AND (~KEYWORD_SET(map_folder)))) THEN BEGIN
         error_code = 299
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Computer is unrecognized, function set_roots_vers.pro did ' + $
            'not assign default folder values, and at least one of the ' + $
            'optional keyword parameters agp_folder, log_folder, ' + $
            'map_folder is not specified.'
         RETURN, error_code
      ENDIF
   ENDIF

   ;  Get the file specification of the AGP file for the specified MISR Path
   ;  and agp_version:
   rc = find_agp_file(misr_path, agp_fspec, $
      AGP_FOLDER = agp_folder, AGP_VERSION = agp_version, $
      VERBOSE = verbose, DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 220
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
      ': ' + excpt_cond
         RETURN, error_code
   ENDIF

   ;  Set the directory address of the folder containing the output log file,
   ;  if it has been requested:
   IF (KEYWORD_SET(log_folder)) THEN BEGIN
      rc = force_path_sep(log_folder, DEBUG = debug, $
         EXCPT_COND = excpt_cond)
      log_fpath = log_folder
   ENDIF ELSE BEGIN
      log_fpath = root_dirs[3] + pb_str_u + PATH_SEP() + 'AGP' + PATH_SEP()
   ENDELSE

   ;  Create the output directory 'log_fpath' if it does not exist, and
   ;  return to the calling routine with an error message if it is unwritable,
   ;  then set the output log file specification:
   IF (KEYWORD_SET(log_it)) THEN BEGIN
      IF (debug) THEN BEGIN
         res = is_writable_dir(log_fpath, /CREATE)
         IF (res NE 1) THEN BEGIN
            error_code = 400
            excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
               rout_name + ': The directory log_fpath is unwritable.'
            RETURN, error_code
         ENDIF
      ENDIF
      log_fname = 'Log_AGP_SurfType_' + pb_str_d + '_' + $
         'r' + strstr(misr_resol) + '_' + agp_version + '_' + date + '.txt'
      log_fspec = log_fpath + log_fname
   ENDIF

   ;  Set the directory address of the folder containing the output map files,
   ;  if they have been requested:
   IF (KEYWORD_SET(map_folder)) THEN BEGIN
      rc = force_path_sep(map_folder, DEBUG = debug, $
         EXCPT_COND = excpt_cond)
      map_fpath = map_folder
   ENDIF ELSE BEGIN
      map_fpath = root_dirs[3] + pb_str_u + PATH_SEP() + 'AGP' + PATH_SEP()
   ENDELSE

   ;  Create the output directory 'map_fpath' if it does not exist, and
   ;  return to the calling routine with an error message if it is unwritable,
   ;  then set the output map file specifications:
   IF (KEYWORD_SET(map_it)) THEN BEGIN
      IF (debug) THEN BEGIN
         res = is_writable_dir(map_fpath, /CREATE)
         IF (res NE 1) THEN BEGIN
            error_code = 410
            excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
               rout_name + ': The directory map_fpath is unwritable.'
            RETURN, error_code
         ENDIF
      ENDIF
      map_fname = STRARR(7)

      map_fname[0] = 'Map_AGP_ShallowOceanMask_' + pb_str_d + '_' + $
         'r' + strstr(misr_resol) + '_' + agp_version + '_' + date + '.png'
      map_fname[1] = 'Map_AGP_LandMask_' + pb_str_d + '_' + $
         'r' + strstr(misr_resol) + '_' + agp_version + '_' + date + '.png'
      map_fname[2] = 'Map_AGP_CoastlineMask_' + pb_str_d + '_' + $
         'r' + strstr(misr_resol) + '_' + agp_version + '_' + date + '.png'
      map_fname[3] = 'Map_AGP_ShallowInlandWaterMask_' + pb_str_d + '_' + $
         'r' + strstr(misr_resol) + '_' + agp_version + '_' + date + '.png'
      map_fname[4] = 'Map_AGP_EphemeralWaterMask_' + pb_str_d + '_' + $
         'r' + strstr(misr_resol) + '_' + agp_version + '_' + date + '.png'
      map_fname[5] = 'Map_AGP_DeepInlandWaterMask_' + pb_str_d + '_' + $
         'r' + strstr(misr_resol) + '_' + agp_version + '_' + date + '.png'
      map_fname[6] = 'Map_AGP_DeepOceanMask_' + pb_str_d + '_' + $
         'r' + strstr(misr_resol) + '_' + agp_version + '_' + date + '.png'

      map_fspec = map_fpath + map_fname
      landcover_fspec = map_fpath + 'Map_AGP_Landcover_' + pb_str_d + '_' + $'
         'r' + strstr(misr_resol) + '_' + agp_version + '_' + date + '.png'
   ENDIF

   ;  Use the MISR Toolkit to designate the region of interest:
   status = MTK_SETREGION_BY_PATH_BLOCKRANGE(misr_path, misr_block, $
      misr_block, region)
   IF (debug AND (status NE 0)) THEN BEGIN
      error_code = 600
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': Error message from MTK_SETREGION_BY_PATH_BLOCKRANGE: ' + $
         MTK_ERROR_MESSAGE(status)
      RETURN, error_code
   ENDIF

   ;  Read the SurfaceFeatureID field in the Standard grid of the MISR AGP
   ;  file and assign it to the BYTE array landcover buffer:
   status = MTK_READDATA(agp_fspec, 'Standard', 'SurfaceFeatureID', $
      region, landcover, mapinfo)
   IF (debug AND (status NE 0)) THEN BEGIN
      error_code = 610
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': Error message from MTK_READDATA: ' + $
         MTK_ERROR_MESSAGE(status)
      RETURN, error_code
   ENDIF

   ;  Upscale the landcover map if high spatial resolution masks are required:
   mask_col = 512
   mask_lin = 128
   IF (misr_resol EQ 275) THEN BEGIN
      mask_col = 2048
      mask_lin = 512
      landcover = lr2hr(landcover, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (excpt_cond NE '') THEN BEGIN
         error_code = 500
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF
   ENDIF

   ;  Define the output positional parameter agp_masks as an array of 7 2D
   ;  arrays, one for each land cover type (initialized with the BYTE value
   ;  0B everywhere), and then assign the BYTE value 1B wherever each land
   ;  cover class is present:
   agp_masks = MAKE_ARRAY(7, mask_col, mask_lin, /BYTE, VALUE = 0B)
   n_pts = LONARR(7)

   ;  - Shallow ocean (landcover code 0):
   map_0 = BYTARR(mask_col, mask_lin)
   idx_0 = WHERE(landcover EQ 0, n)
   IF (n GT 0) THEN map_0[idx_0] = 1B
   n_pts[0] = LONG(n)
   agp_masks[0, *, *] = map_0

   ;  - Land (landcover code 1):
   map_1 = BYTARR(mask_col, mask_lin)
   idx_1 = WHERE(landcover EQ 1, n)
   IF (n GT 0) THEN map_1[idx_1] = 1B
   n_pts[1] = LONG(n)
   agp_masks[1, *, *] = map_1

   ;  - Coastline (landcover code 2):
   map_2 = BYTARR(mask_col, mask_lin)
   idx_2 = WHERE(landcover EQ 2, n)
   IF (n GT 0) THEN map_2[idx_2] = 1B
   n_pts[2] = LONG(n)
   agp_masks[2, *, *] = map_2

   ;  - Shallow inland water (landcover code 3):
   map_3 = BYTARR(mask_col, mask_lin)
   idx_3 = WHERE(landcover EQ 3, n)
   IF (n GT 0) THEN map_3[idx_3] = 1B
   n_pts[3] = LONG(n)
   agp_masks[3, *, *] = map_3

   ;  - Ephemeral water (landcover code 4):
   map_4 = BYTARR(mask_col, mask_lin)
   idx_4 = WHERE(landcover EQ 4, n)
   IF (n GT 0) THEN map_4[idx_4] = 1B
   n_pts[4] = LONG(n)
   agp_masks[4, *, *] = map_4

   ;  - Deep inland water (landcover code 5):
   map_5 = BYTARR(mask_col, mask_lin)
   idx_5 = WHERE(landcover EQ 5, n)
   IF (n GT 0) THEN map_5[idx_5] = 1B
   n_pts[5] = LONG(n)
   agp_masks[5, *, *] = map_5

   ;  - Deep ocean (landcover code 6):
   map_6 = BYTARR(mask_col, mask_lin)
   idx_6 = WHERE(landcover EQ 6, n)
   IF (n GT 0) THEN map_6[idx_6] = 1B
   n_pts[6] = LONG(n)
   agp_masks[6, *, *] = map_6

   ;  Generate the graphic maps if requested: Since each map is a BYTE array
   ;  of values 0 or 1, colors can be assigned by simply multiplying the
   ;  values of these arrays by the color code:
   IF (KEYWORD_SET(map_it)) THEN BEGIN

   ;  - Overall landcover map, with all classes included:
      good_vals = [0B, 1B, 2B, 3B, 4B, 5B, 6B]
      good_vals_cols = ['blue', 'green', 'tan', 'cyan', 'turquoise', $
         'purple', 'navy']
      rc = make_bytemap(landcover, good_vals, good_vals_cols, $
         landcover_fspec, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         error_code = 510
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF

   ;  - Shallow ocean (landcover code 0):
      good_vals = [0B, 1B]
      good_vals_cols = ['black', 'blue']
      rc = make_bytemap(map_0, good_vals, good_vals_cols, $
         map_fspec[0], DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         error_code = 520
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF

   ;  - Land (landcover code 1):
      good_vals = [0B, 1B]
      good_vals_cols = ['black', 'green']
      rc = make_bytemap(map_1, good_vals, good_vals_cols, $
         map_fspec[1], DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         error_code = 530
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF

   ;  - Coastline (landcover code 2):
      good_vals = [0B, 1B]
      good_vals_cols = ['black', 'tan']
      rc = make_bytemap(map_2, good_vals, good_vals_cols, $
         map_fspec[2], DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         error_code = 540
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF

   ;  - Shallow inland water (landcover code 3):
      good_vals = [0B, 1B]
      good_vals_cols = ['black', 'cyan']
      rc = make_bytemap(map_3, good_vals, good_vals_cols, $
         map_fspec[3], DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         error_code = 550
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF

   ;  - Ephemeral water (landcover code 4):
      good_vals = [0B, 1B]
      good_vals_cols = ['black', 'turquoise']
      rc = make_bytemap(map_4, good_vals, good_vals_cols, $
         map_fspec[4], DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         error_code = 560
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF

   ;  - Deep inland water (landcover code 5):
      good_vals = [0B, 1B]
      good_vals_cols = ['black', 'purple']
      rc = make_bytemap(map_5, good_vals, good_vals_cols, $
         map_fspec[5], DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         error_code = 570
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF

   ;  - Deep ocean (landcover code 6):
      good_vals = [0B, 1B]
      good_vals_cols = ['black', 'navy']
      rc = make_bytemap(map_6, good_vals, good_vals_cols, $
         map_fspec[6], DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         error_code = 580
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF
   ENDIF

   ;  Record a summary of the processing in the log file:
   IF (KEYWORD_SET(log_it)) THEN BEGIN
      fmt1 = '(A30, A)'
      OPENW, log_unit, log_fspec, /GET_LUN
      PRINTF, log_unit, 'File name: ', FILE_BASENAME(log_fspec), $
         FORMAT = fmt1
      PRINTF, log_unit, 'Folder name: ', FILE_DIRNAME(log_fspec, $
         /MARK_DIRECTORY), FORMAT = fmt1
      PRINTF, log_unit, 'Generated by: ', rout_name, FORMAT = fmt1
      PRINTF, log_unit, 'Generated on: ', comp_name, FORMAT = fmt1
      PRINTF, log_unit, 'Saved on: ', date_time, FORMAT = fmt1
      PRINTF, log_unit
      content1 = 'Log file created in conjunction with the generation of'
      content2 = 'the AGP land cover masks for the specified Path and Block.'
      PRINTF, log_unit, 'Content: ', content1, FORMAT = fmt1
      PRINTF, log_unit, ' ', content2, FORMAT = fmt1
      PRINTF, log_unit
      PRINTF, log_unit, 'AGP folder name: ', FILE_DIRNAME(agp_fspec, $
         /MARK_DIRECTORY), FORMAT = fmt1
      PRINTF, log_unit, 'AGP file name: ', FILE_BASENAME(agp_fspec), $
         FORMAT = fmt1
      PRINTF, log_unit, 'MISR Path: ', misr_path_str, FORMAT = fmt1
      PRINTF, log_unit, 'MISR Block: ', misr_block_str, FORMAT = fmt1
      PRINTF, log_unit, 'Spatial resolution: ', strstr(misr_resol), $
         FORMAT = fmt1
      PRINTF, log_unit, 'Masks dimensions: ', strstr(mask_col) + $
         ' * ' + strstr(mask_lin), FORMAT = fmt1
      PRINTF, log_unit, 'Number of pixels per mask: ', $
         strstr(LONG(mask_col) * LONG(mask_lin)), FORMAT = fmt1
      PRINTF, log_unit
      PRINTF, log_unit, 'Number of pixels per class:', ' ', FORMAT = fmt1
      PRINTF, log_unit, 'Shallow ocean: ', strstr(n_pts[0]), FORMAT = fmt1
      PRINTF, log_unit, 'Land: ', strstr(n_pts[1]), FORMAT = fmt1
      PRINTF, log_unit, 'Coastline: ', strstr(n_pts[2]), FORMAT = fmt1
      PRINTF, log_unit, 'Shallow inland water: ', strstr(n_pts[3]), $
         FORMAT = fmt1
      PRINTF, log_unit, 'Ephemeral water: ', strstr(n_pts[4]), FORMAT = fmt1
      PRINTF, log_unit, 'Deep inland water: ', strstr(n_pts[5]), $
         FORMAT = fmt1
      PRINTF, log_unit, 'Deep ocean: ', strstr(n_pts[6]), FORMAT = fmt1
      PRINTF, log_unit, 'Sum of number of pixels: ', $
         strstr(LONG(TOTAL(FLOAT(n_pts)))), FORMAT = fmt1

      PRINTF, log_unit
      PRINTF, log_unit, 'The AGP masks map have been saved in'
      PRINTF, log_unit, '   ' + map_fpath
      CLOSE, log_unit
      FREE_LUN, log_unit
   ENDIF

   IF ((verbose GT 0) AND (log_it)) THEN BEGIN
      PRINT, 'The log file has been saved in ' + log_fspec + '.'
   ENDIF
   IF ((verbose GT 0) AND (map_it)) THEN BEGIN
      PRINT, 'The combined land cover map has been saved in'
      PRINT, landcover_fspec
      PRINT, 'The individual landcover maps have been saved in'
      PRINT, map_fspec
   ENDIF
   IF (verbose GT 1) THEN PRINT, 'Exiting ' + rout_name + '.'

   RETURN, return_code

END
