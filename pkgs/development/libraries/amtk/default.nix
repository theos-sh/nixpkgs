{ stdenv
, lib
, fetchurl
, glib
, gtk3
, meson
, mesonEmulatorHook
, ninja
, pkg-config
, gobject-introspection
, gtk-doc
, docbook-xsl-nons
, gnome
, dbus
, xvfb-run
}:

stdenv.mkDerivation rec {
  pname = "amtk";
  version = "5.6.1";

  outputs = [ "out" "dev" "devdoc" ];

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "1QEVuFyHKqwpaTS17nJqP6FWxvWtltJ+Dt0Kpa0XMig=";
  };

  strictDeps = true;
  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    gtk-doc
    docbook-xsl-nons
  ] ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  propagatedBuildInputs = [
    # Required by amtk-5.pc
    glib
    gtk3
  ];

  nativeCheckInputs = [
    dbus # For dbus-run-session
  ];

  doCheck = stdenv.isLinux;
  checkPhase = ''
    runHook preCheck

    export NO_AT_BRIDGE=1
    ${xvfb-run}/bin/xvfb-run -s '-screen 0 800x600x24' dbus-run-session \
      --config-file=${dbus}/share/dbus-1/session.conf \
      meson test --print-errorlogs

    runHook postCheck
  '';

  passthru.updateScript = gnome.updateScript {
    packageName = pname;
    versionPolicy = "none";
  };

  meta = with lib; {
    homepage = "https://wiki.gnome.org/Projects/Amtk";
    description = "Actions, Menus and Toolbars Kit for GTK applications";
    maintainers = [ maintainers.manveru ];
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
  };
}
