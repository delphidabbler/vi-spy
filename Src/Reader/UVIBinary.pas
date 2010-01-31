{
 * UVIBinary.pas
 *
 * Defines a class that wraps object creation entry point exported by
 * VIBinData.dll and dynamically loads and unloads the DLL.
 *
 * $Rev$
 * $Date$
 *
 * ***** BEGIN LICENSE BLOCK *****
 *
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 * 
 * The Original Code is UVIBinary.pas.
 * 
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 * 
 * Portions created by the Initial Developer are Copyright (C) 2002-2010 Peter
 * Johnson. All Rights Reserved.
 * 
 * Contributor(s):
 *   NONE
 * 
 * ***** END LICENSE BLOCK *****
}


unit UVIBinary;


interface


uses
  // Project
  IntfBinaryVerInfo, UDLLLoader;


type

  {
  TVIBinaryLoader:
    Class that wraps object creation entry point exported by VIBinData.dll and
    dynamically loads and unloads the DLL.

    Inheritance: TVIBinaryLoader -> TDDabblerDLLLoader -> TDLLLoader
      -> [TObject]
  }
  TVIBinaryLoader = class(TDDabblerDLLLoader)
  private
    fCreateFunc: TVerInfoBinaryCreateFunc;
      {Reference to entry point in DLL used to create objects within DLL}
  public
    constructor Create;
      {Class constructor: loads DLL and imports required routine from it. An
      exception is raised if DLL can't be found or if routine can't be imported}
    property CreateFunc: TVerInfoBinaryCreateFunc read fCreateFunc;
      {Reference to the function in the DLL that is used to create objects
      within the DLL}
  end;


implementation


uses
  // Delphi
  Windows;


const
  cDLLName = 'VIBinData.dll';     // name of DLL binary version info code
  cEntryPoint = 'CreateInstance'; // name of function in DLL we require


{ TVIBinaryLoader }

constructor TVIBinaryLoader.Create;
  {Class constructor: loads DLL and imports required routine from it. An
  exception is raised if DLL can't be found or if routine can't be imported}
begin
  inherited Create(cDLLName);
  fCreateFunc := LoadRoutine(cEntryPoint, True);
end;

end.
