# https://bthome.io/
def blerry_handle(device, advert)
  var elements = advert.get_elements_by_type_data(0x16, bytes('1C18'), 0)
  if size(elements)
    var data = elements[0].data[2..]
    var i = 0
    var protec = 0
    while i < size(data)
      var fb = data[i]
      var dp_len = fb & 0x1F
      var dp_dtype = (fb & 0xE0) >> 5
      var dp_mtype = data[i+1]
      var dp_rval = data[i+2..i+dp_len]
      var debug_print = false
      var dp_val = nil
      
      if dp_dtype == 0
        dp_val = dp_rval.get(0, dp_len-1)
      elif dp_dtype == 1
        dp_val = dp_rval.geti(0, dp_len-1)
      else 
        debug_print = true
      end

      if dp_val
        if dp_mtype == 0x00
          device.add_attribute('PacketID', dp_val)
        elif dp_mtype == 0x01
          device.add_sensor('Battery', dp_val,  'battery', '%')
        elif dp_mtype == 0x02
          device.add_sensor('Temperature', 0.01*dp_val,  'temperature', '°C')
        elif dp_mtype == 0x03
          device.add_sensor('Humidity', 0.01*dp_val,  'humidity', '%')
        elif dp_mtype == 0x0C
          device.add_sensor('Battery_Voltage', 0.001*dp_val, 'voltage', 'V')
        else
          debug_print = true
        end
      end

      if debug_print
        print('BTHome Debug Data')
        print('len: ' + str(dp_len))
        print('dtype: ' + str(dp_dtype))
        print('mtype: ' + str(dp_mtype))
        print('rval: ' + str(dp_rval))
        print('val ' + str(dp_val))
      end

      i = i + dp_len + 1
      protec = protec + 1
      if protec > 10
        return false
      end
    end
  else
    elements = advert.get_elements_by_type_data(0x16, bytes('D2FC'), 0)
    if size(elements)
      var Meas_Types = {
        0x00: {d='Packet_Id'},
        0x01: {d='Battery',u='%'},
        0x02: {d='Temperature',u='Celsius',d_l=-2,f=0.01},
        0x03: {d='Humidity',u='%',d_l=2,f=0.01},
        0x04: {d='Pressure',u='Mbar',d_l=3,f=0.01},
        0x05: {d='Light',u='Lux',d_l=3,f=0.01},
        0x06: {d='Mass',u='Kg',d_l=2,f=0.01},
        0x07: {d='Mass',u='P',d_l=2,f=0.01},
        0x08: {d='Dew_Point',u='°C',d_l=-2,f=0.01},
        0x09: {d='Count8'},
        0x0a: {d='Energy',u='Kw/H',d_l=3,f=0.001},
        0x0b: {d='Power',u='W',d_l=3,f=0.01},
        0x0c: {d='Voltage',u='V',d_l=2,f=0.001},
        0x0d: {d='Pm25',u='Mg/M3',d_l=2},
        0x0e: {d='Pm10',u='Mg/M3',d_l=2},
        0x0f: {d='Bool_Generic'},
        0x10: {d='Bool_Power'},
        0x11: {d='Bool_Opening'},
        0x12: {d='Co2',u='Ppm',d_l=2},
        0x13: {d='Voc',u='Mg/M3',d_l=2},
        0x14: {d='Moisture',u='%',d_l=2,f=0.01},
        0x15: {d='Bool_Battery'},
        0x16: {d='Bool_Battery_Charging'},
        0x17: {d='Bool_Co'},
        0x18: {d='Bool_Cold'},
        0x19: {d='Bool_Connectivity'},
        0x1a: {d='Bool_Door'},
        0x1b: {d='Bool_Garage_Door'},
        0x1c: {d='Bool_Gas'},
        0x1d: {d='Bool_Heat'},
        0x1e: {d='Bool_Light'},
        0x1f: {d='Bool_Lock'},
        0x20: {d='Bool_Moisture'},
        0x21: {d='Bool_Motion'},
        0x22: {d='Bool_Moving'},
        0x23: {d='Bool_Occupancy'},
        0x24: {d='Bool_Plug'},
        0x25: {d='Bool_Presence'},
        0x26: {d='Bool_Problem'},
        0x27: {d='Bool_Running'},
        0x28: {d='Bool_Safety'},
        0x29: {d='Bool_Smoke'},
        0x2a: {d='Bool_Sound'},
        0x2b: {d='Bool_Tamper'},
        0x2c: {d='Bool_Vibration'},
        0x2d: {d='Bool_Window'},
        0x2e: {d='Humidity',u='%'},
        0x2f: {d='Moisture',u='%'},
        0x3a: {d='Button'},
        0x3c: {d='Dimmer',d_l=2},
        0x3d: {d='Count16',d_l=2},
        0x3e: {d='Count32',d_l=4},
        0x3f: {d='Rotation',u='°',d_l=-2,f=0.1},
        0x40: {d='Distance',u='Mm',d_l=2},
        0x41: {d='Distance',u='M',d_l=2,f=0.1},
        0x42: {d='Duration',u='S',d_l=3,f=0.001},
        0x43: {d='Current',u='A',d_l=2,f=0.001},
        0x44: {d='Speed',u='M/S',d_l=2,f=0.01},
        0x45: {d='Temperature',u='°C',d_l=-2,f=0.1},
        0x46: {d='Uv_Index',d_l=1,f=0.1},
        0x47: {d='Volume',u='L',d_l=2,f=0.1},
        0x48: {d='Volume',u='Ml',d_l=2},
        0x49: {d='Volume_Flow_Rate',u='M3/H',d_l=2,f=0.001},
        0x4a: {d='Voltage',u='V',d_l=2,f=0.1}
    }
    end
  end
  return true
end
blerry_active = false
print('BLY: Driver: BTHome Loaded')
