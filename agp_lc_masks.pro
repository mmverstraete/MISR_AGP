FUNCTION agp_lc_masks, misr_path, misr_block, resol, ocean_mask, $
   land_mask, AGP_VERSION = agp_version, VERBOSE = verbose, $
   MAPIT = mapit, DEBUG = debug, EXCPT_COND = excpt_cond

   ;Sec-Doc
   ;  PURPOSE: This function returns an ocean mask and a land mask based
   ;  on the land cover information available in the MISR AGP file for the
   ;  specified PATH and BLOCK.
   ;
   ;  ALGORITHM: This function retrieves the basic land cover
   ;  classification for the specified PATH and BLOCK from the relevant
   ;  MISR AGP file and generates 2 binary masks, one for the oceanic
   ;  regions and one for the land masses, at the specified spatial
   ;  resolution (either 275 or 1100 m):
   ;
   ;  *   The oceanic mask combines the original classes 0 (shallow ocean)
   ;      and 6 (deep ocean): In that mask, those pixels have a value 1
   ;      while non-ocean pixels have a value 0.
   ;
   ;  *   The land mask combines the original classes 1 (land), 2
   ;      (coastline), 3 (shallow inland water), 4 (ephemeral water), and
   ;      5 (deep inland water): In that mask, those pixels have a value 1
   ;      while non-land pixels have a value 0.
   ;
   ;  The masks are generated at the original low spatial resolution
   ;  (1100 m) of the MISR AGP file, and upscaled to the higher spatial
   ;  resolution (275 m) if requested, usig the function lr2hr.pro.
   ;
   ;  SYNTAX:
   ;  rc = agp_lc_masks(misr_path, misr_block, resol, ocean_mask, $
   ;  land_mask, AGP_VERSION = agp_version, VERBOSE = verbose, $
   ;  MAPIT = mapit, DEBUG = debug, EXCPT_COND = excpt_cond)
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
   ;  *   ocean_mask {INT array} [O]: The binary ocean mask.
   ;
   ;  *   land_mask {INT array} [O]: The binary land mask.
   ;
   ;  KEYWORD PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   AGP_VERSION = agp_version {STRING} [I] (Default value: ’F01_24’):
   ;      The AGP version identifier to use.
   ;
   ;  *   VERBOSE = verbose {INT} [I] (Default value: 0): Flag to activate
   ;      (1) or skip (0) the generation and saving of a log file in a
   ;      subfolder of root_dirs[3].
   ;
   ;  *   MAPIT = mapit {INT} [I] (Default value: 0): Flag to activate (1)
   ;      or skip (0) the generation and saving of a map of the masks in a
   ;      subfolder of root_dirs[3].
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
   ;      provided in the call. The ocean and land binary masks are
   ;      returned as output positional parameters; a log file is created
   ;      and saved if the input keyword parameter VERBOSE is set, and
   ;      maps of both masks are generated and saved if the input keyword
   ;      parameter MAPIT is set in the call.
   ;
   ;  *   If an exception condition has been detected, this function
   ;      returns a non-zero error code, and the output keyword parameter
   ;      excpt_cond contains a message about the exception condition
   ;      encountered, if the optional input keyword parameter DEBUG is
   ;      set and if the optional output keyword parameter EXCPT_COND is
   ;      provided in the call. The ocean and land binary masks may not
   ;      exist or may not be reliable, and any requested output file may
   ;      be inexistent, incomplete or useless.
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
   ;  *   Error 210: An exception condition occurred in block2str.pro when
   ;      converting misr_block1.
   ;
   ;  *   Error 300: The input MISR AGP file agp_spec is unreadable.
   ;
   ;  *   Error 400: The standard output directory out_path is not
   ;      writable, or an exception condition occurred in is_writable.pro.
   ;
   ;  *   Error 500: An exception condition occurred in the MISR TOOLKIT
   ;      routine
   ;      MTK_SETREGION_BY_PATH_BLOCKRANGE.
   ;
   ;  *   Error 510: An exception condition occurred in the MISR TOOLKIT
   ;      routine
   ;      MTK_READDATA.
   ;
   ;  *   Error 520: An exception condition occurred in lr2hr.pro when
   ;      processing the ocean mask.
   ;
   ;  *   Error 530: An exception condition occurred in lr2hr.pro when
   ;      processing the land mask.
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
   ;  *   is_readable.pro
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
   ;      IDL> misr_path = 168
   ;      IDL> misr_block = 112
   ;      IDL> resol = 275
   ;      IDL> agp_lc_masks(misr_path, misr_block, resol, ocean_mask, $
   ;         land_mask, /VERBOSE, /MAPIT, /DEBUG, EXCPT_COND = excpt_cond)
   ;      IDL> PRINT, 'rc = ' + strstr(rc) + ', excpt_cond = >' + excpt_cond + '<'
   ;      rc = 0, excpt_cond = ><
   ;
   ;  REFERENCES:
   ;
   ;  *   Mike Bull, Jason Matthews, Duncan McDonald, Alexander Menzies,
   ;      Catherine Moroney, Kevin Mueller, Susan Paradise, Mike
   ;      Smyth (2011) MISR Data Products Specifications, JPL D-13963,
   ;      Revision S, Section 9.4, p. 210.
   ;
   ;  VERSIONING:
   ;
   ;  *   2018–05–13: Version 0.9 — Initial release.
   ;
   ;  *   2018–05–14: Version 1.0 — Initial public release.
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

   ;  Initialize the output positional parameters to invalid or improbable
   ;  values, to ensure that a lack of value assignment is detectable:
   ocean_mask = INTARR(512, 128)
   ocean_mask[*, *] = -1
   land_mask = INTARR(512, 128)
   land_mask[*, *] = -1

   IF (debug) THEN BEGIN

   ;  Return to the calling routine with an error message if this function is
   ;  called with the wrong number of required positional parameters:
      n_reqs = 5
      IF (N_PARAMS() NE n_reqs) THEN BEGIN
         info = SCOPE_TRACEBACK(/STRUCTURE)
         rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
         error_code = 100
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Routine must be called with ' + strstr(n_reqs) + $
            ' positional parameter(s): misr_path, misr_block, ' + $
            'resol, ocean_mask, land_mask.'
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

   ;  If the input keyword parameter AGP_VERSION is not specified, set
   ;  the default value to Version 'F01_24':
   IF (~KEYWORD_SET(agp_version)) THEN agp_version = 'F01_24'

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

   ;  Set the file specification of the appropriate MISR AGP input file:
   agp_path = root_dirs[0]
   agp_file = 'MISR_AM1_AGP_' + misr_path_str + '_' + agp_version + '.hdf'
   agp_spec = agp_path + agp_file

   ;  Return to the calling routine with an error message if the input
   ;  file 'agp_spec' does not exist or is unreadable:
   rc = is_readable(agp_spec, DEBUG = debug, EXCPT_COND = excpt_cond)
   IF ((debug) AND (rc LT 1)) THEN BEGIN
      info = SCOPE_TRACEBACK(/STRUCTURE)
      rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
      error_code = 300
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

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

   ;  Set the output map file specification, if it has been requested:
   IF (KEYWORD_SET(mapit)) THEN BEGIN
      oce_map_file = 'map-AGP-OceanMask_' + pb_str + '_' + agp_version + '.png'
      oce_map_spec = out_path + oce_map_file
      lnd_map_file = 'map-AGP-LandMask_' + pb_str + '_' + agp_version + '.png'
      lnd_map_spec = out_path + lnd_map_file
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

   ;  Initialize the ocean and land masks as copies of the original landcover
   ;  buffer:
   ocean_mask = landcover
   land_mask = landcover

   ;  Identify the pixels that are flagged as shallow or deep ocean in the
   ;  original MISR AGP file and define the ocean mask:
   idx_oce = WHERE(((landcover EQ 0) OR (landcover EQ 6)), n_ocean)
   ocean_mask[*, *] = 0
   IF (n_ocean GT 0) THEN ocean_mask[idx_oce] = 1

   ;  Identify the pixels that are neither shallow nor deep ocean in the
   ;  original MISR AGP file and define the land mask:
   idx_lnd = WHERE(((landcover GT 0) AND (landcover LT 6)), n_land)
   land_mask[*, *] = 0
   IF (n_land GT 0) THEN land_mask[idx_lnd] = 1

   ;  Upscale these masks if they are required at the high spatial resolution:
   IF (resol EQ 275) THEN BEGIN
      tmp = lr2hr(ocean_mask, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (excpt_cond NE '') THEN BEGIN
         info = SCOPE_TRACEBACK(/STRUCTURE)
         rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
         error_code = 520
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF
      ocean_mask = tmp

      tmp = lr2hr(land_mask, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (excpt_cond NE '') THEN BEGIN
         info = SCOPE_TRACEBACK(/STRUCTURE)
         rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
         error_code = 530
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF
      land_mask = tmp
   ENDIF

   ;  Retrieve the dimensions of the ocean mask (the land mask has identical
   ;  dimensions):
   mask_size = SIZE(ocean_mask)
   mask_col = mask_size[1]
   mask_lin = mask_size[2]

   ;  Generate the graphic map is requested:
   IF (KEYWORD_SET(mapit)) THEN BEGIN

   ;  Define the BYTE arrays that will contain the graphic representation of
   ;  the land and ocean masks:
      ommap = BYTARR(mask_col, mask_lin)
      lmmap = BYTARR(mask_col, mask_lin)

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

   ;  Initialize all pixels to black:
      ommap[*, *] = black
      lmmap[*, *] = black

   ;  Assign colors to the land and ocean areas in the masks:
      idx_oce = WHERE(ocean_mask EQ 1, n_ocean)
      IF (n_ocean GT 0) THEN ommap[idx_oce] = blue
      idx_lnd = WHERE(land_mask EQ 1, n_land)
      IF (n_land GT 0) THEN lmmap[idx_lnd] = green

   ;  Save the PNG files:
      WRITE_PNG, oce_map_spec, ommap, r, g, b, /ORDER
      WRITE_PNG, lnd_map_spec, lmmap, r, g, b, /ORDER
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
      PRINTF, log_unit, 'Number of ocean pixels: ', strstr(n_ocean), $
         FORMAT = fmt1
      PRINTF, log_unit, 'Number of land pixels: ', strstr(n_land), $
         FORMAT = fmt1
      PRINTF, log_unit
      PRINTF, log_unit, 'The AGP ocean mask map has been saved in'
      PRINTF, log_unit, '   ' + oce_map_spec
      PRINTF, log_unit, 'The AGP land mask map has been saved in'
      PRINTF, log_unit, '   ' + lnd_map_spec
      CLOSE, log_unit
      FREE_LUN, log_unit
   ENDIF

   RETURN, return_code

END
