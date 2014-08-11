unit MissileSpeeds;
// this unit creates two objectlists with missile speed data Vanilla/CMOD4
// querying these ingame is not working for some reason...

interface

  uses Contnrs, Classes;

  type TMissile = class(TObject)
  private
    Name : string;
    Speed : integer;
    constructor Create(MissileName:string; MissileSpeed:integer);
  end;

  var
    VanillaMissiles : TObjectlist;
    CMOD4Missiles : TObjectlist;

implementation

  var SaveExit : pointer;

  procedure FreeLists; far;
  begin
    ExitProc := SaveExit;
    VanillaMissiles.Free;
    CMOD4Missiles.Free;
  end {NewExit};

  procedure PopulateLists();
  begin
    SaveExit := ExitProc;
    ExitProc := @FreeLists;

    VanillaMissiles:=TObjectList.Create(True);
    CMOD4Missiles:=TObjectList.Create(True);

    with VanillaMissiles do
    begin
      Add(TMissile.create('Banshee',153));
      Add(TMissile.Create('Tomahawk',196));
      Add(TMissile.Create('Hornet',186));
      Add(TMissile.Create('Thorn',158));
      Add(TMissile.Create('Typhoon',195));
      Add(TMissile.Create('Firestorm',165));
      Add(TMissile.Create('Hammer',253));
      Add(TMissile.Create('Flail',486));
      Add(TMissile.Create('Boarding',480));
      Add(TMissile.Create('Poltergeist',250));
      Add(TMissile.Create('Wraith',170));
      Add(TMissile.Create('Spectre',190));
      Add(TMissile.Create('Shadow',245));
      Add(TMissile.Create('Ghoul',450));
      Add(TMissile.Create('Phantom',212));
      Add(TMissile.Create('Sting',257));
      Add(TMissile.Create('Needle',500));
      Add(TMissile.Create('Windstalker',179));
      Add(TMissile.Create('Wildfire',246));
      Add(TMissile.Create('Disruptor',514));
      Add(TMissile.Create('Hammerhead',172));
      Add(TMissile.Create('Beluga',211));
      Add(TMissile.Create('Remote',142));
      Add(TMissile.Create('Firefly',576));
      Add(TMissile.Create('Thunderbolt',195));
      Add(TMissile.Create('Aurora',589));
      Add(TMissile.Create('Tornado',312));
      Add(TMissile.Create('Cyclone',148));
      Add(TMissile.Create('Tempest',195));
      Add(TMissile.Create('Hurricane',471));
      Add(TMissile.Create('Silkworm',190));
      Add(TMissile.Create('Mosquito',590));
      Add(TMissile.Create('Firelance',500));
      Add(TMissile.Create('Wasp',560));
      Add(TMissile.Create('Rapier',657));
      Add(TMissile.Create('Dragonfly',250));
   end;

   with CMOD4Missiles do
    begin
      Add(TMissile.create('Banshee',230));
      Add(TMissile.Create('Tomahawk',196));
      Add(TMissile.Create('Hornet',349));
      Add(TMissile.Create('Thorn',244));
      Add(TMissile.Create('Typhoon',230));
      Add(TMissile.Create('Firestorm',250));
      Add(TMissile.Create('Hammer',400));
      Add(TMissile.Create('Flail',486));
      Add(TMissile.Create('Boarding',480));
      Add(TMissile.Create('Poltergeist',250));
      Add(TMissile.Create('Wraith',275));
      Add(TMissile.Create('Spectre',250));
      Add(TMissile.Create('Shadow',245));
      Add(TMissile.Create('Ghoul',450));
      Add(TMissile.Create('Phantom',212));
      Add(TMissile.Create('Sting',290));
      Add(TMissile.Create('Needle',235));
      Add(TMissile.Create('Windstalker',553));
      Add(TMissile.Create('Wildfire',246));
      Add(TMissile.Create('Disruptor',514));
      Add(TMissile.Create('Hammerhead',300));
      Add(TMissile.Create('Beluga',211));
      Add(TMissile.Create('Remote',170));
      Add(TMissile.Create('Firefly',900));
      Add(TMissile.Create('Thunderbolt',240));
      Add(TMissile.Create('Aurora',1450));
      Add(TMissile.Create('Tornado',360));
      Add(TMissile.Create('Cyclone',260));
      Add(TMissile.Create('Tempest',250));
      Add(TMissile.Create('Hurricane',471));
      Add(TMissile.Create('Silkworm',220));
      Add(TMissile.Create('Mosquito',590));
      Add(TMissile.Create('Firelance',110));
      Add(TMissile.Create('Wasp',560));
      Add(TMissile.Create('Rapier',657));
      Add(TMissile.Create('Dragonfly',310));
   end;
  end;

{ TMissile }
constructor TMissile.Create(MissileName: string; MissileSpeed: integer);
begin
  inherited Create();
  Name:=MissileName;
  Speed:=MissileSpeed;
end;

begin
  PopulateLists();
end.


