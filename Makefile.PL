use inc::Module::Install;

name     'Net-Google-Code';
all_from 'lib/Net/Google/Code.pm';
author   'sunnavy <sunnavy@bestpractical.com>';
license  'perl';

build_requires 'Test::More';
build_requires 'Test::MockModule';
requires 'Moose';
requires 'WWW::Mechanize';
requires 'HTML::TreeBuilder';
requires 'Params::Validate';

auto_install;

WriteAll;

