use inc::Module::Install;

name     'Net-Google-Code';
all_from 'lib/Net/Google/Code.pm';
author   'sunnavy <sunnavy@bestpractical.com>';
license  'perl';

test_requires 'Test::More';
test_requires 'Test::MockModule';
test_requires 'File::Slurp';
requires 'Moose';
requires 'WWW::Mechanize';
requires 'HTML::TreeBuilder';
requires 'Params::Validate';
requires 'XML::Atom';
requires 'Term::ReadPassword';

auto_install;

WriteAll;

