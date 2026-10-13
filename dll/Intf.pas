unit Intf;

interface
 uses sysutils,windows,ActiveX;
 type

 pDriverData=^DriverData;
 DriverData=record
  AddrDrv         :dword;        // адрес драйвера, для определения от какого драйвера
                                 // пришел пакет данных или какому драйверу предназначен
                                 // пакет
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
