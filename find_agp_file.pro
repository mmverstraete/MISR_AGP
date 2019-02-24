FUNCTION find_agp_file, $
   misr_path, $
   agp_fspec, $
   AGP_FOLDER = agp_folder, $
   AGP_VERSION = agp_version, $
   DEBUG = debug, $
   EXCPT_COND = excpt_cond

   ;Sec-Doc
   ;  PURPOSE: This function provides the file specification (path + name)
   ;  of the MISR AGP file corresponding to the given misr_path and
   ;  optional agp_version, if it is available either in the default
   ;  folder (defined by the function set_roots_vers.pro), or in the
   ;  folder specified by the optional input keyword parameter agp_folder.
   ;
   ;  ALGORITHM: This function searches the folder root_dirs[0], or the
   ;  folder specified by the optional input keyword parameter agp_folder,
   ;  if provided, for the AGP file corresponding to the input positional
   ;  parameter misr_path and the optionally specified version, and
   ;  provides the full file specification (path and name) of that file if
   ;  it is found, through the output positional argument agp_fspec.
   ;
   ;  SYNTAX: rc = find_agp_file(misr_path, agp_fspec, $
   ;  AGP_FOLDER = agp_folder, AGP_VERSION = agp_version, $
   ;  DEBUG = debug, EXCPT_COND = excpt_cond)
   ;
   ;  POSITIONAL PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   misr_path {INT} [I]: The selected MISR PATH number.
   ;
   ;  *   agp_fspec {STRING} [O]: The file specification of the MISR AGP
   ;      file for the selected PATH.
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
   ;      a null string, if the optional input keyword parameter DEBUG was
   ;      set and if the optional output keyword parameter EXCPT_COND was
   ;      provided in the call. The output positional parameter agp_fspec
   ;      contains the full specification of the MISR AGP file.
   ;
   ;  *   If an exception condition has been detected, this function
   ;      returns a non-zero error code, and the output keyword parameter
   ;      excpt_cond contains a message about the exception condition
   ;      encountered, if the optional input keyword parameter DEBUG is
   ;      set and if the optional output keyword parameter EXCPT_COND is
   ;      provided. The output positional parameter agp_fspec may be
   ;      inexistent, incomplete or incorrect.
   ;
   ;  EXCEPTION CONDITIONS:
   ;
   ;  *   Error 100: One or more positional parameter(s) are missing.
   ;
   ;  *   Error 110: Input argument misr_path is invalid.
   ;
   ;  *   Error 199: An exception condition occurred in function
   ;      set_roots_vers.
   ;
   ;  *   Error 200: An exception condition occurred in function
   ;      path2str.pro.
   ;
   ;  *   Error 210: This computer is unrecognized and no alternate
   ;      directory address to the AGP folder is provided.
   ;
   ;  *   Error 300: No MISR AGP file has been found.
   ;
   ;  *   Error 310: More than 1 MISR AGP file has been found.
   ;
   ;  *   Error 320: The MISR AGP file exists but is unreadable.
   ;
   ;  *   Error 330: An exception condition occurred in function
   ;      is_readable.pro.
   ;
   ;  *   Error 340: The MISR AGP file does not exist.
   ;
   ;  DEPENDENCIES:
   ;
   ;  *   MISR Toolkit
   ;
   ;  *   chk_misr_path.pro
   ;
   ;  *   is_readable.pro
   ;
   ;  *   path2str.pro
   ;
   ;  *   set_roots_vers.pro
   ;
   ;  *   strstr.pro
   ;
   ;  REMARKS: None.
   ;
   ;  EXAMPLES:
   ;
   ;      IDL> misr_path = 168
   ;      IDL> rc = find_agp_file(misr_path, agp_fspec, $
   ;         AGP_FOLDER = '', AGP_VERSION = agp_version, $
   ;         /DEBUG, EXCPT_COND = excpt_cond)
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
   ;
   ;  *   2018–05–16: Version 1.5 — Implement new coding standards.
   ;
   ;  *   2018–12–15: Version 1.6 — Add the optional input keyword
   ;      parameter AGP_FOLDER.
   ;
   ;  *   2019–01–28: Version 2.00 — Systematic update of all routines to
   ;      implement stricter coding standards and improve documentation.
   ;
   ;  *   2019–02–24: Version 2.01 — Documentation update.
   ;Sec-Lic
   ;  INTELLECTUAL PROPERTY RIGHTS
   ;
   ;  *   Copyright (C) 2017-2019 Michel M. Verstraete.
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
   ;      be included in its entirety in all copies or substantial
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
   IF KEYWORD_SET(debug) THEN debug = 1 ELSE debug = 0
   excpt_cond = ''

   ;  Initialize the output positional parameters:
   agp_fspec = ''

   IF (debug) THEN BEGIN

   ;  Return to the calling routine with an error message if one or more
   ;  positional parameters are missing:
      n_reqs = 2
      IF (N_PARAMS() NE n_reqs) THEN BEGIN
         error_code = 100
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Routine must be called with ' + strstr(n_reqs) + $
            ' positional parameter(s): misr_path, agp_fspec.'
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

   ;  Generate the long string version of the MISR Path number:
   rc = path2str(misr_path, misr_path_s, /NOHEADER, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 200
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  Return to the calling routine with an error message if the routine
   ;  set_roots_vers.pro could not assign valid values to the array root_dirs
   ;  and the required MISR and MISR-HR root folders have not been initialized:
   IF (debug AND (rc_roots EQ 99)) THEN BEGIN
      IF (~KEYWORD_SET(agp_folder)) THEN BEGIN
         error_code = 210
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond + ' And keyword parameter agp_folder is not set.'
         RETURN, error_code
      ENDIF
   ENDIF

   ;  Set the directory address of the folder containing the input AGP files:
   IF (KEYWORD_SET(agp_folder)) THEN BEGIN
      agp_fpath = force_path_sep(agp_folder, DEBUG = debug, $
         EXCPT_COND = excpt_cond)
   ENDIF ELSE BEGIN
      agp_fpath = root_dirs[0] + 'AGP' + PATH_SEP()
   ENDELSE

   ;  Generate the specification of the AGP file:
   status = MTK_MAKE_FILENAME(agp_fpath, 'AGP', '', misr_path_s, '', $
      agp_version, agp_fspec)

   ;  Verify that this file specification points to a single file and does
   ;  not contain wildcard characters such as * or ?):
   files = FILE_SEARCH(agp_fspec, COUNT = n_files)
   IF (debug) THEN BEGIN
      IF (n_files EQ 0) THEN BEGIN
         error_code = 300
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': No file corresponds to the specification for agp_fspec.'
         RETURN, error_code
      ENDIF
      IF (n_files GT 1) THEN BEGIN
         error_code = 310
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Multiple files correspond to the specification for agp_fspec.'
         RETURN, error_code
      ENDIF
   ENDIF
   agp_fspec = files[0]

   ;  Return to the calling routine with an error message if this AGP
   ;  file is unreadable:
   IF (debug) THEN BEGIN
      rc = is_readable(agp_fspec, DEBUG = debug, EXCPT_COND = excpt_cond)
      CASE rc OF
         1: BREAK
         0: BEGIN
               error_code = 320
               excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
                  rout_name + ': The input file ' + in_file + $
                  ' exists but is unreadable.'
               RETURN, error_code
            END
         -1: BEGIN
               IF (debug) THEN BEGIN
                  error_code = 330
                  excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
                     rout_name + ': ' + excpt_cond
                  RETURN, error_code
               ENDIF
            END
         -2: BEGIN
               error_code = 340
               excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
                  rout_name + ': The input file ' + in_file + ' does not exist.'
               RETURN, error_code
            END
         ELSE: BREAK
      ENDCASE
   ENDIF

   RETURN, return_code

END
