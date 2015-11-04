Summary: Installs and configures Foreman.
Name: pupmod-foreman
Version: 0.1.0
Release: 1
License: Apache License, Version 2.0
Group: Applications/System
Source: %{name}-%{version}-%{release}.tar.gz
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
Requires: pupmod-iptables >= 2.0.0-0
Requires: puppet >= 3.3.0
Buildarch: noarch

Prefix: /etc/puppet/environments/simp/modules

%description
Installs and configures Foreman.

%prep
%setup -q

%build

%install
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/foreman

dirs='files lib manifests templates'
for dir in $dirs; do
  test -d $dir && cp -r $dir %{buildroot}/%{prefix}/foreman
done

%clean
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/foreman

%files
%defattr(0640,root,puppet,0750)
%{prefix}/foreman

%post
#!/bin/sh

%postun
# Post uninstall stuff

%changelog
* Wed Nov 04 2015 Chris Tessmer <chris.tessmer@onyxpoint.com> - 0.1.0-1
- Initial package, minor bug fixes and structural updates in preparation for
  inclusion in next SIMP release.

* Thu Sep 10 2015 kendall-moore <kendall8688@gmail.com> - 0.1.0-0
- Initial module (on behalf of Kendall Moore, original author).
