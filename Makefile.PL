use inc::Module::Install;

name     'Net-Google-Code';
all_from 'lib/Net/Google/Code.pm';
author   'sunnavy <sunnavy@bestpractical.com>';
license  'perl';

build_requires 'Test::More';

auto_install;

WriteAll;

