FUNCTION make_agp_masks, misr_path, misr_block, resol, masks, $
   AGP_VERSION = agp_version, VERBOSE = verbose, MAPIT = mapit, $
   DEBUG = debug, EXCPT_COND = excpt_cond

   ;Sec-Doc
   ;  PURPOSE: This function returns an array of 7 masks based on the
   ;  landcover information available in the AGP file for the specified
   ;  MISR PATH and BLOCK.
   ;
   ;  ALGORITHM: This function retrieves the basic landcover
   ;  classification for the specified PATH and BLOCK from the relevant
   ;  MISR AGP file and generates 7 individual binary masks, one for each
   ;  recognized class, at the specified spatial resolution (either 275 or
   ;  1100 m). Within each mask, each pixel is assigned the value 0 if
   ;  that location does not belong to that class, or a non-zero BYTE
   ;  color code if it does. A log file is generated if the optional
   ;  keyword parameter VERBOSE is specified, and each mask is also saved
   ;  as a map if the optional keyword parameter MAPIT is set. In that
   ;  case, the land cover categories are assigned the following colors:
   ;
   ;  *   landcover code 0: Shallow ocean, blue.
   ;
   ;  *   landcover code 1: Land, green.
   ;
   ;  *   landcover code 2: Coastline, sand.
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
   ;  resolution (275 m) if requested, usig the function lr2hr.pro.
   ;
   ;  SYNTAX: rc = agp_lc_(misr_path, misr_block, resol, masks, $
   ;  AGP_VERSION = agp_version, VERBOSE = verbose, MAPIT = mapit, $
   ;  DEBUG = debug, EXCPT_COND = excpt_cond)
   ;
   ;  POSITIONAL PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   misr_path {INT} [I]: The specified MISR PATH number.
   ;
   ;  *   misr_block {INT} [I]: The specified initial MISR BLOCK number.
   ;
   ;  *   resol {INT} [I]: The required spatial resolution of the output
   ;      mask: either 275 or 1100 (in m).
   ;
   ;  *   masks INT array [O]: The array of 7 binary masks.
   ;
   ;  KEYWORD PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   ∘]
   ;      AGP_VERSION = agp_version {STRING} [I] (Default value: ’F01_24’):
   ;      The AGP version identifier to use.
   ;
   ;  *   ∘] VERBOSE = verbose {INT} [I] (Default value: 0): Flag to
   ;      activate (1) or skip (0) the generation and saving of a log file
   ;      in a subfolder of root_dirs[3].
   ;
   ;  *   ∘] MAPIT = mapit {INT} [I] (Default value: 0): Flag to
   ;      activate (1) or skip (0) the generation and saving of maps of
   ;      the masks in a subfolder of root_dirs[3].
   ;
   ;  *   DEBUG = debug {INT} [I] (Default value: 0): Flag to activate (1)
   ;      or skip (0) debugging tests.
   ;
   ;  *   EXCPT_COND = excpt_cond {STRING} [O] (Default value: ”):
   ;      Description of the exception condition if one has been
   ;      encountered, or a null string otherwise.
   ;
   ;  RETURNED VALUE TYPE: INTEGER.
   ;
   ;  OUTCOME:
   ;
   ;  *   If no exception condition has been detected, this function
   ;      returns 0, and the output keyword parameter excpt_cond is set to
   ;      a null string, if the optional input keyword parameter DEBUG is
   ;      set and if the optional output keyword parameter EXCPT_COND is
   ;      provided in the call. The array of binary masks is returned as
   ;      output positional parameter; a log file is created and saved if
   ;      the input keyword parameter VERBOSE is set, and maps of both
   ;      masks are generated and saved if the input keyword parameter
   ;      MAPIT is set in the call.
   ;
   ;  *   If an exception condition has been detected, this function
   ;      returns a non-zero error code, and the output keyword parameter
   ;      excpt_cond contains a message about the exception condition
   ;      encountered, if the optional input keyword parameter DEBUG is
   ;      set and if the optional output keyword parameter EXCPT_COND is
   ;      provided in the call. The array of binary masks may not be
   ;      defined, and any requested output file may be inexistent,
   ;      incomplete or useless.
   ;
   ;  EXCEPTION CONDITIONS:
   ;
   ;  *   Error 100: One or more positional parameter(s) are missing.
   ;
   ;  *   Error 110: The input positional parameter misr_path is invalid.
   ;
   ;  *   Error 120: The input positional parameters misr_block is
   ;      invalid.
   ;
   ;  *   Error 130: The input positional parameters resol is invalid.
   ;
   ;  *   Error 200: An exception condition occurred in path2str.pro.
   ;
   ;  *   Error 210: An exception condition occurred in block2str.pro.
   ;
   ;  *   Error 300: An exception condition occurred in get_agp_file.pro.
   ;
   ;  *   Error 400: The standard output directory out_path is not
   ;      writable, or an exception condition occurred in is_writable.pro.
   ;
   ;  *   Error 500: An exception condition occurred in the MISR TOOLKIT
   ;      routine MTK_SETREGION_BY_PATH_BLOCKRANGE.
   ;
   ;  *   Error 510: An exception condition occurred in the MISR TOOLKIT
   ;      routine MTK_READDATA.
   ;
   ;  *   Error 520: An exception condition occurred in lr2hr.pro.
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
   ;  *   get_agp_file.pro
   ;
   ;  *   is_writable.pro
   ;
   ;  *   lr2hr.pro
   ;
   ;  *   path2str.pro
   ;
   ;  *   set_root_dirs.pro
   ;
   ;  *   strstr.pro
   ;
   ;  *   today.pro
   ;
   ;  REMARKS: None.
   ;
   ;  EXAMPLES:
   ;
   ;      [Insert the command and its outcome]
   ;
   ;  REFERENCES:
   ;
   ;  *   Mike Bull, Jason Matthews, Duncan McDonald, Alexander Menzies,
   ;      Catherine Moroney, Kevin Mueller, Susan Paradise, Mike
   ;      Smyth (2011) _MISR Data Products Specifications_, JPL D-13963,
   ;      Revision S, Section 9.4, p. 210.
   ;
   ;  VERSIONING:
   ;
   ;  *   2018–05–13: Version 0.9 — Initial release.
   ;
   ;  *   2018–05–15: Version 1.0 — Initial public release.
   ;Sec-Lic
   ;  INTELLECTUAL PROPERTY RIGHTS
   ;
   ;  *   Copyright (C) 2017-2018 Michel M. Verstraete.
   ;
   ;      Permission is hereby granted, free of charge, to any person
   ;      obtaining a copy of this software and associated documentation
   ;      files (the “Software”), to deal in the Software without
   ;      restriction, including without limitation the rights to use,
   ;      copy, modify, merge, publish, distribute, sublicense, and/or
   ;      sell copies of the Software, and to permit persons to whom the
   ;      Software is furnished to do so, subject to the following
   ;      conditions:
   ;
   ;      The above copyright notice and this permission notice shall be
   ;      included in all copies or substantial portions of the Software.
   ;
   ;      THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
   ;      EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
   ;      OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
   ;      NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
   ;      HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
   ;      WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
   ;      FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
   ;      OTHER DEALINGS IN THE SOFTWARE.
   ;
   ;      See: https://opensource.org/licenses/MIT.
   ;
   ;  *   Feedback
   ;
   ;      Please send comments and suggestions to the author at
   ;      MMVerstraete@gmail.com.
   ;Sec-Cod
   ;  Initialize the default return code and the exception condition message:
   return_code = 0
   IF KEYWORD_SET(debug) THEN BEGIN
      debug = 1
   ENDIF ELSE BEGIN
      debug = 0
   ENDELSE
   excpt_cond = ''

   IF (debug) THEN BEGIN

   ;  Return to the calling routine with an error message if this function is
   ;  called with the wrong number of required positional parameters:
      n_reqs = 4
      IF (N_PARAMS() NE n_reqs) THEN BEGIN
         info = SCOPE_TRACEBACK(/STRUCTURE)
         rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
         error_code = 100
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Routine must be called with ' + strstr(n_reqs) + $
            ' positional parameter(s): misr_path, misr_block, ' + $
            'resol, masks.'
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if the input
   ;  positional parameter 'misr_path' is invalid:
      rc = chk_misr_path(misr_path, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         info = SCOPE_TRACEBACK(/STRUCTURE)
         rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
         error_code = 110
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if the input
   ;  positional parameter 'misr_block' is invalid:
      rc = chk_misr_block(misr_block, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         info = SCOPE_TRACEBACK(/STRUCTURE)
         rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
         error_code = 120
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if the input spatial
   ;  resolution 'resol' is invalid:
      IF ((resol NE 275) AND (resol NE 1100)) THEN BEGIN
         info = SCOPE_TRACEBACK(/STRUCTURE)
         rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
         error_code = 130
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': The requested spatial resolution must be either 275 or 1100 (m).'
         RETURN, error_code
      ENDIF
   ENDIF

   ;  Generate the string version of the MISR Path number:
   rc = path2str(misr_path, misr_path_str, DEBUG = debug, $
      EXCPT_COND = excpt_cond)
   IF ((debug) AND (rc NE 0)) THEN BEGIN
      info = SCOPE_TRACEBACK(/STRUCTURE)
      rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
      error_code = 200
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  Generate the string version of the MISR Block number:
   rc = block2str(misr_block, misr_block_str, DEBUG = debug, $
      EXCPT_COND = excpt_cond)
   IF ((debug) AND (rc NE 0)) THEN BEGIN
      info = SCOPE_TRACEBACK(/STRUCTURE)
      rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
      error_code = 210
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF
   pb_str = misr_path_str + '_' + misr_block_str

   ;  Identify the current computer:
   SPAWN, 'hostname -s', computer
   computer = computer[0]

   ;  Set the standard locations for MISR files on this computer:
   root_dirs = set_root_dirs()

   ;  Get the name of this routine:
   info = SCOPE_TRACEBACK(/STRUCTURE)
   rout_name = info[N_ELEMENTS(info) - 1].ROUTINE

   ;  Get today's date and time:
   date_time = today(FMT = 'nice')

   ;  Get the file specification of the AGP file for the specified MISR Path and
   ;  optional agp_version
   rc = get_agp_file(misr_path, agp_spec, AGP_VERSION = agp_version, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF ((debug) AND (rc NE 0)) THEN BEGIN
      info = SCOPE_TRACEBACK(/STRUCTURE)
      rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
      error_code = 300
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
      ': ' + excpt_cond
         RETURN, error_code
   ENDIF

      ;  If the input keyword parameter AGP_VERSION is not specified, set
      ;  the default value to Version 'F01_24':
   ;   IF (~KEYWORD_SET(agp_version)) THEN agp_version = 'F01_24'


   ;  Set the file specification of the appropriate MISR AGP input file:
;   agp_path = root_dirs[0]
;   agp_file = 'MISR_AM1_AGP_' + misr_path_str + '_' + agp_version + '.hdf'
;   agp_spec = agp_path + agp_file

   ;  Return to the calling routine with an error message if the input
   ;  file 'agp_spec' does not exist or is unreadable:
;   rc = is_readable(agp_spec, DEBUG = debug, EXCPT_COND = excpt_cond)
;   IF ((debug) AND (rc LT 1)) THEN BEGIN
;      info = SCOPE_TRACEBACK(/STRUCTURE)
;      rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
;      error_code = 300
;      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
;         ': ' + excpt_cond
;      RETURN, error_code
;   ENDIF

   ;  Set the output folder for the log and/or the map file, if either has
   ;  been requested:
   IF (KEYWORD_SET(verbose) OR KEYWORD_SET(mapit)) THEN BEGIN
      out_path = root_dirs[3] + pb_str + '/AGP/'

   ;  Return to the calling routine with an error message if the output
   ;  directory 'out_path' is not writable:
      rc = is_writable(out_path, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF ((debug) AND ((rc EQ 0) OR (rc EQ -1))) THEN BEGIN
         info = SCOPE_TRACEBACK(/STRUCTURE)
         rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
         error_code = 400
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF
      IF (rc EQ -2) THEN FILE_MKDIR, out_path
   ENDIF

   ;  Set the output log file specification, if it has been requested:
   IF (KEYWORD_SET(verbose)) THEN BEGIN
      log_file = 'map-AGP-LogMasks_' + pb_str + '_' + agp_version + '.txt'
      log_spec = out_path + log_file
   ENDIF

   ;  Set the file specifications of the output maps, if they have been
   ;  requested:
   IF (KEYWORD_SET(mapit)) THEN BEGIN
      map_file = STRARR(7)

      map_file[0] = 'map-AGP-ShallowOceanMask_' + pb_str + '_' + $
         agp_version + '.png'
      map_file[1] = 'map-AGP-LandMask_' + pb_str + '_' + $
         agp_version + '.png'
      map_file[2] = 'map-AGP-CoastlineMask_' + pb_str + '_' + $
         agp_version + '.png'
      map_file[3] = 'map-AGP-ShallowInlandWaterMask_' + pb_str + '_' + $
         agp_version + '.png'
      map_file[4] = 'map-AGP-EphemeralWaterMask_' + pb_str + '_' + $
         agp_version + '.png'
      map_file[5] = 'map-AGP-DeepInlandWaterMask_' + pb_str + '_' + $
         agp_version + '.png'
      map_file[6] = 'map-AGP-DeepOceanMask_' + pb_str + '_' + $
         agp_version + '.png'

      map_spec = out_path + map_file
   ENDIF

   ;  Use the MISR Toolkit to designate the region of interest:
   status = MTK_SETREGION_BY_PATH_BLOCKRANGE(misr_path, misr_block, $
      misr_block, region)
   IF ((debug) AND (status NE 0)) THEN BEGIN
      info = SCOPE_TRACEBACK(/STRUCTURE)
      rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
      error_code = 500
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': status from MTK_SETREGION_BY_PATH_BLOCKRANGE = ' + strstr(status)
      RETURN, error_code
   ENDIF

   ;  Read the SurfaceFeatureID field in the Standard grid of the MISR AGP
   ;  file and assign it to the landcover buffer:
   status = MTK_READDATA(agp_spec, 'Standard', 'SurfaceFeatureID', $
      region, landcover, mapinfo)
   IF ((debug) AND (status NE 0)) THEN BEGIN
      info = SCOPE_TRACEBACK(/STRUCTURE)
      rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
      error_code = 510
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': status from MTK_READDATA = ' + strstr(status)
      RETURN, error_code
   ENDIF

   ;  Upscale the landcover map if high spatial resolution masks (and
   ;  optionally maps) are required:
   mask_col = 512
   mask_lin = 128
   IF (resol EQ 275) THEN BEGIN
      mask_col = 2048
      mask_lin = 512
      landcover = lr2hr(landcover, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (excpt_cond NE '') THEN BEGIN
         info = SCOPE_TRACEBACK(/STRUCTURE)
         rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
         error_code = 520
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF
   ENDIF

   ;  Set up colors for plotting: each (r, g, b) column defines a corresponding
   ;  intensity in the RGB channels:
   ;  Note: This table defines more colors than needed by this routine, but
   ;  other masks could be defined.
   r = [  0, 255,   0,   0, 255,   0, 255, 255, 255, 100, 200, 255,   0,  64]
   g = [  0,   0, 255,   0, 255, 255,   0, 255, 100, 100, 200, 215,   0, 224]
   b = [  0,   0,   0, 255,   0, 255, 255, 255,   0, 100, 200,   0, 139, 208]

   black = 0
   red = 1
   green = 2
   blue = 3
   yellow = 4
   cyan = 5
   purple = 6
   white = 7
   orange = 8
   lgrey = 9
   dgrey = 10
   sand = 11
   navy = 12
   turquoise = 13

   ;  Set the masks for the various land cover types and assign a color where
   ;  the corresponding pixels belong to the specified type:
   n_pts = LONARR(7)
   masks = BYTARR(7, mask_col, mask_lin)

   ;  - Shallow ocean (landcover code 0):
   map_0 = BYTARR(mask_col, mask_lin)
   idx_0 = WHERE(landcover EQ 0, n)
   n_pts[0] = n
   masks[0, *, *] = map_0

   ;  - Land (landcover code 1):
   map_1 = BYTARR(mask_col, mask_lin)
   idx_1 = WHERE(landcover EQ 1, n)
   n_pts[1] = n
   masks[1, *, *] = map_1

   ;  - Coastline (landcover code 2):
   map_2 = BYTARR(mask_col, mask_lin)
   idx_2 = WHERE(landcover EQ 2, n)
   n_pts[2] = n
   masks[2, *, *] = map_2

   ;  - Shallow inland water (landcover code 3):
   map_3 = BYTARR(mask_col, mask_lin)
   idx_3 = WHERE(landcover EQ 3, n)
   n_pts[3] = n
   masks[3, *, *] = map_3

   ;  - Ephemeral water (landcover code 4):
   map_4 = BYTARR(mask_col, mask_lin)
   idx_4 = WHERE(landcover EQ 4, n)
   n_pts[4] = n
   masks[4, *, *] = map_4

   ;  - Deep inland water (landcover code 5):
   map_5 = BYTARR(mask_col, mask_lin)
   idx_5 = WHERE(landcover EQ 5, n)
   n_pts[5] = n
   masks[5, *, *] = map_5

   ;  - Deep ocean (landcover code 6):
   map_6 = BYTARR(mask_col, mask_lin)
   idx_6 = WHERE(landcover EQ 6, n)
   n_pts[6] = n
   masks[6, *, *] = map_6

   ;  Generate the graphic maps is requested:
   IF (KEYWORD_SET(mapit)) THEN BEGIN

   ;  - Shallow ocean (landcover code 0) - blue (color code 3):
      IF (n_pts[0] GT 0) THEN map_0[idx_0] = blue
      WRITE_PNG, map_spec[0], map_0, r, g, b, /ORDER

   ;  - Land (landcover code 1) - green (color code 2):
      IF (n_pts[1] GT 0) THEN map_1[idx_1] = green
      WRITE_PNG, map_spec[1], map_1, r, g, b, /ORDER

   ;  - Coastline (landcover code 2) - sand (color code 11):
      IF (n_pts[2] GT 0) THEN map_2[idx_2] = sand
      WRITE_PNG, map_spec[2], map_2, r, g, b, /ORDER

   ;  - Shallow inland water (landcover code 3) - cyan (color code 5):
      IF (n_pts[3] GT 0) THEN map_3[idx_3] = cyan
      WRITE_PNG, map_spec[3], map_3, r, g, b, /ORDER

   ;  - Ephemeral water (landcover code 4) - turquoise (color code 13):
      IF (n_pts[4] GT 0) THEN map_4[idx_4] = turquoise
      WRITE_PNG, map_spec[4], map_4, r, g, b, /ORDER

   ;  - Deep inland water (landcover code 5) - purple (color code 6):
      IF (n_pts[5] GT 0) THEN map_5[idx_5] = purple
      WRITE_PNG, map_spec[5], map_5, r, g, b, /ORDER

   ;  - Deep ocean (landcover code 6) - navy (color code 12):
      IF (n_pts[6] GT 0) THEN map_6[idx_6] = navy
      WRITE_PNG, map_spec[6], map_6, r, g, b, /ORDER
   ENDIF

   ;  Record a summary of the processing in the log file:
   IF (KEYWORD_SET(verbose)) THEN BEGIN
      fmt1 = '(A30, A)'
      OPENW, log_unit, log_spec, /GET_LUN
      PRINTF, log_unit, "File name: ", "'" + log_file + "'", FORMAT = fmt1
      PRINTF, log_unit, "Folder name: ", out_path + "'", FORMAT = fmt1
      PRINTF, log_unit, 'Generated by: ', rout_name, FORMAT = fmt1
      PRINTF, log_unit, 'Generated on: ', computer, FORMAT = fmt1
      PRINTF, log_unit, 'Saved on: ', date_time, FORMAT = fmt1
      PRINTF, log_unit
      content = 'Log file.'
      PRINTF, log_unit, 'Content: ', content, FORMAT = fmt1
      PRINTF, log_unit
      PRINTF, log_unit, 'AGP folder name: ', FILE_DIRNAME(agp_spec, $
         /MARK_DIRECTORY), FORMAT = fmt1
      PRINTF, log_unit, 'AGP file name: ', FILE_BASENAME(agp_spec), $
         FORMAT = fmt1
      PRINTF, log_unit, 'MISR Path: ', misr_path_str, FORMAT = fmt1
      PRINTF, log_unit, 'MISR Block: ', misr_block_str, FORMAT = fmt1
      PRINTF, log_unit, 'Spatial resolution: ', strstr(resol), FORMAT = fmt1
      PRINTF, log_unit, 'Masks dimensions: ', strstr(mask_col) + $
         ' * ' + strstr(mask_lin), FORMAT = fmt1
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
      PRINTF, log_unit
      PRINTF, log_unit, 'The AGP masks map have been saved in'
      PRINTF, log_unit, '   ' + out_path
      CLOSE, log_unit
      FREE_LUN, log_unit
   ENDIF

   RETURN, return_code

END
