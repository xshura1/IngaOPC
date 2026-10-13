unit Intf;

interface
 uses sysutils,windows,ActiveX;
 type

 pDriverData=^DriverData;
 DriverData=record
  Handle          :dword;
  szAddress       :POleStr;
  szNoCommand     :POleStr;
  Param           :dword;
  dwDataSize      :dword;
  pData           :PByteArray;
  Result          :dword;
 end;

implementation

end.
