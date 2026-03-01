#!/usr/bin/env python3
"""
Bluetooth Auto-Confirming Agent
Automatically accepts all Bluetooth pairing requests
"""

import sys
import dbus
import dbus.service
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib

class Agent(dbus.service.Object):
    exit_on_release = False

    def __init__(self, bus, path):
        dbus.service.Object.__init__(self, bus, path)
        self.last_passkey = None

    def set_exit_on_release(self, exit_on_release):
        self.exit_on_release = exit_on_release

    @dbus.service.method("org.bluez.Agent1", in_signature="os", out_signature="")
    def AuthorizeService(self, device, uuid):
        print(f"[BT AGENT] Authorizing service on {device}: {uuid}")
        return

    @dbus.service.method("org.bluez.Agent1", in_signature="ou", out_signature="")
    def DisplayPasskey(self, device, passkey):
        print(f"[BT AGENT] Passkey displayed on {device}: {passkey:06d}")
        self.last_passkey = passkey

    @dbus.service.method("org.bluez.Agent1", in_signature="os", out_signature="u")
    def RequestPasskey(self, device, confirmed):
        print(f"[BT AGENT] Passkey requested for {device}")
        return dbus.UInt32(0)

    @dbus.service.method("org.bluez.Agent1", in_signature="ou", out_signature="")
    def RequestConfirmation(self, device, passkey):
        print(f"[BT AGENT] Confirming passkey {passkey:06d} for {device}")
        self.last_passkey = passkey

    @dbus.service.method("org.bluez.Agent1", in_signature="", out_signature="")
    def RequestAuthorization(self, device):
        print(f"[BT AGENT] Authorization requested for {device}")

    @dbus.service.method("org.bluez.Agent1", in_signature="", out_signature="")
    def Cancel(self):
        print("[BT AGENT] Pairing canceled")

    @dbus.service.method("org.bluez.Agent1", in_signature="", out_signature="")
    def Release(self):
        print("[BT AGENT] Agent released")
        if self.exit_on_release:
            mainloop.quit()

if __name__ == '__main__':
    DBusGMainLoop(set_as_default=True)
    bus = dbus.SystemBus()
    
    # Register agent
    agent = Agent(bus, "/org/bluez/agent")
    agent.set_exit_on_release(True)
    
    obj = bus.get_object("org.bluez", "/org/bluez")
    manager = dbus.Interface(obj, "org.bluez.AgentManager1")
    
    try:
        manager.RegisterAgent("/org/bluez/agent", "DisplayYesNo")
        print("[BT AGENT] Agent registered successfully")
    except dbus.DBusException as e:
        print(f"[BT AGENT] Failed to register agent: {e}")
        sys.exit(1)
    
    # Make it the default agent
    try:
        manager.RequestDefaultAgent("/org/bluez/agent")
        print("[BT AGENT] Set as default agent")
    except dbus.DBusException as e:
        print(f"[BT AGENT] Warning: Could not set as default: {e}")
    
    # Run the event loop
    mainloop = GLib.MainLoop()
    print("[BT AGENT] Listening for pairing requests... (Press Ctrl+C to stop)")
    
    try:
        mainloop.run()
    except KeyboardInterrupt:
        print("\n[BT AGENT] Shutting down...")
        manager.UnregisterAgent("/org/bluez/agent")
