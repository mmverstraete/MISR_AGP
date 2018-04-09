FUNCTION map_agp_lc_blocks, misr_path, misr_block1, misr_block2, $
   AGP_VERSION = agp_version, DEBUG = debug, EXCPT_COND = excpt_cond

   ;Sec-Doc
   ;  PURPOSE: This function generates and saves a map of the land cover
   ;  type assumed by the MISR ground segment for the specified PATH and
   ;  for the range of BLOCKS from misr_block1 to misr_block2 (inclusive).
   ;
   ;  ALGORITHM: This function reads the MISR AGP file for the specified
   ;  PATH, extracts and maps the land cover information contained in the
   ;  field SurfaceFeatureID for the range of Blocks from misr_block1 to
   ;  misr_block2 inclusive.
   ;
   ;  SYNTAX:
   ;  rc = map_agp_lc_blocks(misr_path, misr_block1, misr_block2, $
   ;  AGP_VERSION = agp_version, DEBUG = debug, EXCPT_COND = excpt_cond)
   ;
   ;  POSITIONAL PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   misr_path {INTEGER} [I]: The selected MISR PATH number.
   ;
   ;  *   misr_block1 {INTEGER} [I]: The selected starting MISR BLOCK
   ;      number to be mapped.
   ;
   ;  *   misr_block2 {INTEGER} [I]: The selected ending MISR BLOCK number
   ;      to be mapped.
   ;
   ;  KEYWORD PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   AGP_VERSION = agp_version {STRING} [I] The MISR AGP version to
   ;      use.
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
   ;      a null string, if the optional input keyword parameter DEBUG was
   ;      set and if the optional output keyword parameter EXCPT_COND was
   ;      provided in the call. A log file and the land cover map used
   ;      during the processing of MISR data (largely a land/sea mask) for
   ;      the selected MISR PATH and for the indicated range of BLOCKS is
   ;      saved in the expected location root_dirs[3] + ’Pxxx_Bzzz/AGP/’
   ;      folder.
   ;
   ;  *   If an exception condition has been detected, this function
   ;      returns a non-zero error code, and the output keyword parameter
   ;      excpt_cond contains a message about the exception condition
   ;      encountered, if the optional input keyword parameter DEBUG is
   ;      set and if the optional output keyword parameter EXCPT_COND is
   ;      provided. The log file and the land cover map may not have been
   ;      produced or may be incomplete or useless.
   ;
   ;  EXCEPTION CONDITIONS:
   ;
   ;  *   Error 100: One or more positional parameter(s) are missing.
   ;
   ;  *   Error 110: The input positional parameter MISR PATH is invalid.
   ;
   ;  *   Error 130: The input positional parameters MISR BLOCK1 is
   ;      invalid.
   ;
   ;  *   Error 132: The input positional parameters MISR BLOCK2 is
   ;      invalid.
   ;
   ;  *   Error 210: An exception condition occurred in path2str.pro.
   ;
   ;  *   Error 230: An exception condition occurred in block2str.pro.
   ;
   ;  *   Error 232: An exception condition occurred in block2str.pro.
   ;
   ;  *   Error 300: An exception condition occurred in get_agp_file.pro.
   ;
   ;  *   Error 310: An exception condition occurred in the MISR TOOLKIT
   ;      routine
   ;      MTK_SETREGION_BY_PATH_BLOCKRANGE.
   ;
   ;  *   Error 320: The output folder to contain the land cover map
   ;      exists but is not writable.
   ;
   ;  *   Error 400: The sum of the numbers of pixels in the 7 land cover
   ;      types does not match the total number of pixels in the AGP file.
   ;
   ;  DEPENDENCIES:
   ;
   ;  *   MISR Toolkit
   ;
   ;  *   get_agp_file.pro
   ;
   ;  *   strstr.pro
   ;
   ;  REMARKS:
   ;
   ;  *   NOTE 1: This function currently does not check the validity of
   ;      the optional input keyword parameter agp_version.
   ;
   ;  *   NOTE 2: If this function is called with a range of BLOCKS
   ;      spanning more than a single BLOCK, the log file and the map aare
   ;      saved in the folder root_dirs[2] + [MISR Path]_[MISR Block1]/.
   ;
   ;  *   NOTE 3: This land cover map is primarily used as a land/ocean
   ;      mask in two instances within the MISR ground segment: (1) after
   ;      generating the Ellipsoid-projected L1B2 data everywhere, that
   ;      mask is used to generate the Terrain-projected data files only
   ;      for those BLOCKS that contain land masses, and (2) within the L2
   ;      characterization of atmospheric properties, the same land/ocean
   ;      mask is also used to choose between the ocean-specific or the
   ;      land-specific aerosol algorithm. This map is not intended to be
   ;      used for other purposes; factual errors will be corrected when
   ;      generating a new version, but there is no intention to make it
   ;      more discriminating, as such information is not used by the MISR
   ;      ground segment.
   ;
   ;  EXAMPLES:
   ;
   ;      IDL> rc = map_agp_lc_blocks(168, 108, 114, AGP_VERSION = 'F01_24', $
   ;         /DEBUG, EXCPT_COND = excpt_cond)
   ;      The map of AGP land cover has been saved in
   ;      [misr_roots[2]]/P168_B108/AGP/map-AGP_P168_B108_B114_LC_F01_24_2018-02-21.png
   ;
   ;  REFERENCES:
   ;
   ;  *   Scott A. Lewicki and Jia Zong (1999) ’Level 1 Ancillary
   ;      Geographic Product Algorithm Theoretical Basis’, JPL D-13400,
   ;      Revision A, available from
   ;      https://eospso.gsfc.nasa.gov/sites/default/files/atbd/atbd-misr-05.pdf.
   ;
   ;  *   Mike Bull, Jason Matthews, Duncan McDonald, Alexander Menzies,
   ;      Catherine Moroney, Kevin Mueller, Susan Paradise and Mike
   ;      Smyth (2011) ’Data Products Specifications’, JPL D-13963,
   ;      Revision S, available from
   ;      https://eosweb.larc.nasa.gov/project/misr/DPS_v50_RevS.pdf.
   ;
   ;  VERSIONING:
   ;
   ;  *   2017–12–10: Version 0.9 — Initial release.
   ;
   ;  *   2018–03–10: Version 1.0 — Initial public release.
   ;
   ;  *   2018–04–08: Version 1.1 — Update this function to use
   ;      set_root_dirs.pro instead of set_misr_roots.pro, and update the
   ;      documentation.
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
      n_reqs = 3
      IF (N_PARAMS() NE n_reqs) THEN BEGIN
         info = SCOPE_TRACEBACK(/STRUCTURE)
         rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
         error_code = 100
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Routine must be called with ' + strstr(n_reqs) + $
            ' positional parameters: misr_path, misr_block1, misr_block2.'
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if this function is
   ;  called with an invalid misr_path argument:
      rc = chk_misr_path(misr_path, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         info = SCOPE_TRACEBACK(/STRUCTURE)
         rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
         error_code = 110
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if this function is
   ;  called with an invalid misr_block1 argument:
      rc = chk_misr_block(misr_block1, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         info = SCOPE_TRACEBACK(/STRUCTURE)
         rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
         error_code = 130
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if this function is
   ;  called with an invalid misr_block2 argument:
      rc = chk_misr_block(misr_block2, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         info = SCOPE_TRACEBACK(/STRUCTURE)
         rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
         error_code = 132
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF

   ;  Check that misr_block1 is less than or equal to misr_block2, and if not,
   ;  exchange the 2 values:
      IF (misr_block1 GT misr_block2) THEN BEGIN
         temp = misr_block2
         misr_block2 = misr_block1
         misr_block1 = temp
      ENDIF
   ENDIF

   ;  Generate the string versions of the MISR Path, Block1 and Block2 numbers:
   rc = path2str(misr_path, misr_path_str, DEBUG = debug, $
      EXCPT_COND = excpt_cond)
   IF ((debug) AND (rc NE 0)) THEN BEGIN
      info = SCOPE_TRACEBACK(/STRUCTURE)
      rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
      error_code = 210
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF
   rc = block2str(misr_block1, misr_block1_str, DEBUG = debug, $
      EXCPT_COND = excpt_cond)
   IF ((debug) AND (rc NE 0)) THEN BEGIN
      info = SCOPE_TRACEBACK(/STRUCTURE)
      rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
      error_code = 230
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF
   rc = block2str(misr_block2, misr_block2_str, DEBUG = debug, $
      EXCPT_COND = excpt_cond)
   IF ((debug) AND (rc NE 0)) THEN BEGIN
      info = SCOPE_TRACEBACK(/STRUCTURE)
      rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
      error_code = 232
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF
   pb_str = misr_path_str + '_' + misr_block1_str
   pbb_str = misr_path_str + '_' + misr_block1_str + '_' + misr_block2_str

   ;  If no agp_version number is specified, use Version 'F01_24':
   IF NOT(KEYWORD_SET(agp_version)) THEN agp_version = 'F01_24'

   ;  Get the name of this routine:
   info = SCOPE_TRACEBACK(/STRUCTURE)
   rout_name = info[N_ELEMENTS(info) - 1].ROUTINE

   ;  Get the current date:
   date = today(FMT = 'ymd')
   date_time = today(FMT = 'nice')

   ;  Get the file specification of the AGP file:
   rc = get_agp_file(misr_path, agp_fspec, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF ((debug) AND (rc NE 0)) THEN BEGIN
      info = SCOPE_TRACEBACK(/STRUCTURE)
      rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
      error_code = 300
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  Set the designated Block range as the region of interest:
   status = MTK_SETREGION_BY_PATH_BLOCKRANGE(misr_path, misr_block1, $
      misr_block2, region)
   IF ((debug) AND (status NE 0)) THEN BEGIN
      info = SCOPE_TRACEBACK(/STRUCTURE)
      rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
      error_code = 310
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': status from MTK_SETREGION_BY_PATH_BLOCKRANGE = ' + strstr(status)
      RETURN, error_code
   ENDIF

   ;  Set the root directories for the MISR-HR project:
   root_dirs = set_root_dirs()

   ;  Define the standard directory in which to save the map and the log file:
   local_path = 'AGP' + PATH_SEP()
   map_path = root_dirs[3] + pb_str + PATH_SEP() + local_path

   ;  Create this output directory if it does not already exist:
   rc_d = is_dir(map_path, DEBUG = debug, EXCPT_COND = excpt_cond)
   rc_w = is_writable(map_path, DEBUG = debug, EXCPT_COND = excpt_cond)
   IF ((rc_d NE 1) OR (rc_w EQ -1)) THEN BEGIN
      FILE_MKDIR, map_path
   ENDIF
   IF ((debug) AND (rc_w EQ 0)) THEN BEGIN
      info = SCOPE_TRACEBACK(/STRUCTURE)
      rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
      error_code = 320
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': Directory ' + map_path + ' exists but is not writable.'
      RETURN, error_code
   ENDIF

   ;  Read the AGP file and determine the dimensions of the landcover array:
   status = MTK_READDATA(agp_fspec, 'Standard', 'SurfaceFeatureID', $
      region, landcover, mapinfo)
   size_lc = SIZE(landcover)

   ;  Generate the specification of the log file:
   local_name = 'map-AGP_' + pbb_str + '_LC_' + agp_version + '_' + $
      date
   log_spec = map_path + local_name + '.txt'
   fmt1 = '(A25, A)'

   ;  Generate the specification of the land cover map file:
   map_spec = map_path + local_name + '.png'

   ;  Open the log file and start recording events:
   OPENW, log_unit, log_spec, /GET_LUN
   PRINTF, log_unit, 'File name: ', FILE_BASENAME(log_spec), $
      FORMAT = fmt1
   PRINTF, log_unit, 'Folder name: ', FILE_DIRNAME(log_spec), $
      FORMAT = fmt1
   PRINTF, log_unit, 'Generated by: ', rout_name, FORMAT = fmt1
   PRINTF, log_unit, 'Saved on: ', date_time, FORMAT = fmt1
   PRINTF, log_unit

   PRINTF, log_unit, 'Content: ', 'Log file created in conjunction with ' + $
      'the generation of', FORMAT = fmt1
   PRINTF, log_unit, '', 'the AGP land cover map for the specified Path ' + $
      'and Block(s).', FORMAT = fmt1
   PRINTF, log_unit

   PRINTF, log_unit
   PRINTF, log_unit, 'Input AGP directory: ', $
      FILE_DIRNAME(agp_fspec, /MARK_DIRECTORY), FORMAT = fmt1
   PRINTF, log_unit, 'Input AGP filename: ', $
      FILE_BASENAME(agp_fspec), FORMAT = fmt1
   PRINTF, log_unit, '   misr_path: ', misr_path_str, FORMAT = fmt1
   PRINTF, log_unit, ' misr_block1: ', misr_block1_str, FORMAT = fmt1
   PRINTF, log_unit, ' misr_block2: ', misr_block2_str, FORMAT = fmt1
   PRINTF, log_unit, 'Area of interest: ', '', FORMAT = fmt1
   PRINTF, log_unit, '     n_lines: ', strstr(size_lc[2]), FORMAT = fmt1
   PRINTF, log_unit, '   n_samples: ', strstr(size_lc[1]), FORMAT = fmt1
   PRINTF, log_unit, '    n_pixels: ', strstr(size_lc[4]), FORMAT = fmt1
   PRINTF, log_unit, ' AGP version: ', agp_version, FORMAT = fmt1
   PRINTF, log_unit, '  Map folder: ', map_path, FORMAT = fmt1
   PRINTF, log_unit, 'Map filename: ', local_name, FORMAT = fmt1
   PRINTF, log_unit

   ;  Save the color coding in the log file:
   PRINTF, log_unit, 'Color coding convention: ', '', FORMAT = fmt1
   PRINTF, log_unit, '        Navy: ', 'Deep Ocean', FORMAT = fmt1
   PRINTF, log_unit, '        Blue: ', 'Shallow Ocean', FORMAT = fmt1
   PRINTF, log_unit, '        Sand: ', 'Coastline', FORMAT = fmt1
   PRINTF, log_unit, '       Green: ', 'Land', FORMAT = fmt1
   PRINTF, log_unit, '      Purple: ', 'Ephemeral Water', FORMAT = fmt1
   PRINTF, log_unit, '        Cyan: ', 'Shallow Inland Water', FORMAT = fmt1
   PRINTF, log_unit, '   Turquoise: ', 'Deep Inland Water', FORMAT = fmt1
   PRINTF, log_unit

   ;  Extract the various land cover types from the AGP buffer:
   shoc = WHERE(landcover EQ 0, nshoc)
   land = WHERE(landcover EQ 1, nland)
   coas = WHERE(landcover EQ 2, ncoas)
   shin = WHERE(landcover EQ 3, nshin)
   epwa = WHERE(landcover EQ 4, nepwa)
   dewa = WHERE(landcover EQ 5, ndewa)
   deoc = WHERE(landcover EQ 6, ndeoc)

   ;  Define the array that will contain the map:
   lcmap = BYTARR(size_lc[1], size_lc[2])

   ;  Report on the number of pixels found in each land cover class:
   PRINTF, log_unit, 'Landcover distribution: ', '', FORMAT = fmt1
   PRINTF, log_unit, '    Number of pixels: ', strstr(size_lc[4]), FORMAT = fmt1
   PRINTF, log_unit, '          Deep ocean: ', strstr(ndeoc), FORMAT = fmt1
   PRINTF, log_unit, '       Shallow ocean: ', strstr(nshoc), FORMAT = fmt1
   PRINTF, log_unit, '           Coastline: ', strstr(ncoas), FORMAT = fmt1
   PRINTF, log_unit, '                Land: ', strstr(nland), FORMAT = fmt1
   PRINTF, log_unit, '     Ephemeral water: ', strstr(nepwa), FORMAT = fmt1
   PRINTF, log_unit, 'Shallow inland water: ', strstr(nshin), FORMAT = fmt1
   PRINTF, log_unit, '   Deep inland water: ', strstr(ndewa), FORMAT = fmt1
   sum = ndeoc + nshoc + ncoas + nland + nepwa + nshin + ndewa
   PRINTF, log_unit, '  Sum of cover types: ', strstr(sum), FORMAT = fmt1
   IF (sum NE size_lc[4]) THEN BEGIN
      info = SCOPE_TRACEBACK(/STRUCTURE)
      rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
      error_code = 400
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': The sum of the numbers of pixels in the 7 land cover types ' + $
         'does not match the total number of pixels in the AGP file.'
      CLOSE, log_unit
      RETURN, error_code
   ENDIF
   PRINTF, log_unit

   ;  Set up colors for plotting: each (r, g, b) column defines a corresponding
   ;  intensity in the RGB channels. This table defines more colors than needed
   ;  by this routine:
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
   lcmap[*, *] = black

   ;  Assign colors to the various land cover types:
   IF (nshoc GT 0) THEN lcmap[shoc] = blue
   IF (nland GT 0) THEN lcmap[land] = green
   IF (ncoas GT 0) THEN lcmap[coas] = sand
   IF (nshin GT 0) THEN lcmap[shin] = cyan
   IF (nepwa GT 0) THEN lcmap[epwa] = purple
   IF (ndewa GT 0) THEN lcmap[dewa] = turquoise
   IF (ndeoc GT 0) THEN lcmap[deoc] = navy

   ;  Write the PNG file:
   WRITE_PNG, map_spec, lcmap, r, g, b, /ORDER

   PRINT, 'The map of AGP land cover ' + $
      'has been saved in ' + map_spec
   PRINTF, log_unit

   FREE_LUN, log_unit
   CLOSE, /ALL

   RETURN, return_code

END
