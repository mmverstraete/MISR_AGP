FUNCTION get_agp_file, misr_path, agp_fspec, $
   AGP_VERSION = agp_version, DEBUG = debug, EXCPT_COND = excpt_cond

   ;Sec-Doc
   ;  PURPOSE: This function provides the file specification (path + name)
   ;  of the MISR AGP file corresponding to the given misr_path and
   ;  optional agp_version, if they are available in the expected input
   ;  folder (defined by the function set_root_dirs) on the current
   ;  computer.
   ;
   ;  ALGORITHM: This function searches the folder root_dirs[0] for an AGP
   ;  file of the optionally specified version, and provides the full file
   ;  specification (path and name) of that file if it is found, in the
   ;  output positional argument agp_fspec.
   ;
   ;  SYNTAX: rc = get_agp_file(misr_path, agp_fspec, $
   ;  AGP_VERSION = agp_version, DEBUG = debug, EXCPT_COND = excpt_cond)
   ;
   ;  POSITIONAL PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   misr_path {INTEGER} [I]: The selected MISR PATH number.
   ;
   ;  *   agp_fspec {STRING} [O]: The file specification of the MISR AGP
   ;      file for the selected PATH.
   ;
   ;  KEYWORD PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   AGP_VERSION = agp_version {STRING} [I] (Default value: ’F01_24’):
   ;      The MISR AGP version to use.
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
   ;      provided in the call. The output positional parameter agp_fspec
   ;      contains the full specification for the MISR AGP file.
   ;
   ;  *   If an exception condition has been detected, this function
   ;      returns a non-zero error code, and the output keyword parameter
   ;      excpt_cond contains a message about the exception condition
   ;      encountered, if the optional input keyword parameter DEBUG is
   ;      set and if the optional output keyword parameter EXCPT_COND is
   ;      provided. The output positional parameter agp_fspec is set to a
   ;      null string.
   ;
   ;  EXCEPTION CONDITIONS:
   ;
   ;  *   Error 100: One or more positional parameter(s) are missing.
   ;
   ;  *   Error 110: Input argument misr_path is invalid.
   ;
   ;  *   Error 210: An exception condition occurred in function
   ;      path2str.pro.
   ;
   ;  *   Error 300: No MISR AGP file has been found.
   ;
   ;  *   Error 310: More than 1 MISR AGP file has been found.
   ;
   ;  *   Error 320: An exception condition occurred in function
   ;      is_readable.pro.
   ;
   ;  DEPENDENCIES:
   ;
   ;  *   chk_misr_path.pro
   ;
   ;  *   is_readable.pro
   ;
   ;  *   path2str.pro
   ;
   ;  *   set_root_dirs.pro
   ;
   ;  *   strstr.pro
   ;
   ;  REMARKS: None.
   ;
   ;  EXAMPLES:
   ;
   ;      IDL> misr_path = 168
   ;      IDL> rc = get_agp_file(misr_path, agp_fspec, $
   ;         AGP_VERSION = agp_version, /DEBUG, $
   ;         EXCPT_COND = excpt_cond)
   ;      IDL> PRINT, 'rc = ' + strstr(rc) + ', $
   ;         excpt_cond = >' + excpt_cond + '<'
   ;      rc = 0, excpt_cond = ><
   ;      IDL> PRINT, 'agp_fspec = ' + agp_fspec
   ;      agp_fspec =
   ;         /Users/michel/MISR_HR/Input/AGP/MISR_AM1_AGP_P168_F01_24.hdf
   ;
   ;  REFERENCES: None.
   ;
   ;  VERSIONING:
   ;
   ;  *   2018–02–12: Version 1.0 — Initial release.
   ;
   ;  *   2018–03–26: Version 1.1 — Initial public release.
   ;
   ;  *   2018–04–08: Version 1.2 — Update this function to use
   ;      set_root_dirs.pro instead of set_misr_roots.pro.
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

   ;  Initialize the output positional parameters to invalid values:
   agp_fspec = ''

   IF (debug) THEN BEGIN

   ;  Return to the calling routine with an error message if this function is
   ;  called with the wrong number of required positional parameters:
      n_reqs = 2
      IF (N_PARAMS() NE n_reqs) THEN BEGIN
         info = SCOPE_TRACEBACK(/STRUCTURE)
         rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
         error_code = 100
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Routine must be called with ' + strstr(n_reqs) + $
            ' positional parameter(s): misr_path, agp_fspec.'
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if this function is
   ;  called with invalid misr_path or misr_orbit arguments:
      rc = chk_misr_path(misr_path, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         info = SCOPE_TRACEBACK(/STRUCTURE)
         rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
         error_code = 110
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF
   ENDIF

   ;  Set the string version of the MISR Path number:
   rc = path2str(misr_path, misr_path_str, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF ((debug) AND (rc NE 0)) THEN BEGIN
      info = SCOPE_TRACEBACK(/STRUCTURE)
      rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
      error_code = 210
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  If no agp_version number is specified, use Version 'F01_24':
   IF (~KEYWORD_SET(agp_version)) THEN agp_version = 'F01_24'

   ;  Set the root directories for the MISR-HR project:
   root_dirs = set_root_dirs()

   ;  Generate the specification of the AGP file:
   agp_file = 'MISR_AM1_AGP_' + misr_path_str + '_' + agp_version + '.hdf'
   agp_path = root_dirs[0]
   agp_fspec = agp_path + agp_file

   ;  Ensure that no wildcard characters are left in the file specification:
   files = FILE_SEARCH(agp_fspec, COUNT = nfiles)

   IF (debug) THEN BEGIN
      IF (nfiles EQ 0) THEN BEGIN
         info = SCOPE_TRACEBACK(/STRUCTURE)
         rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
         error_code = 300
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': No AGP file was found for Path ' + misr_path_str + '.'
         RETURN, error_code
      ENDIF
      IF (nfiles GT 1) THEN BEGIN
         info = SCOPE_TRACEBACK(/STRUCTURE)
         rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
         error_code = 310
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': More than one AGP file was found for Path ' + misr_path_str + '.'
         RETURN, error_code
      ENDIF
   ENDIF
   agp_fspec = files[0]

   ;  Return to the calling routine with an error message if the input
   ;  file 'agp_fspec' does not exist or is unreadable:
   IF (debug) THEN BEGIN
      rc = is_readable(agp_fspec, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc LT 1) THEN BEGIN
         info = SCOPE_TRACEBACK(/STRUCTURE)
         rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
         error_code = 320
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF
   ENDIF

   RETURN, return_code

END
