use t::Util;
use App::git::ship::perl;

{
  my $app = App::git::ship::perl->new;
  like $app->_changes_to_commit_message, qr{Released version [\d\._]+\n\n\s+}, '_changes_to_commit_message()';
}

t::Util->goto_workdir('perl-ship', 0);

my $upload_file;
eval <<'DUMMY' or die $@;
package CPAN::Uploader;
sub new { bless $_[1], $_[0] }
sub read_config_file { {} }
sub upload_file { $upload_file = $_[1] }
$INC{'CPAN/Uploader.pm'} = 'dummy';
DUMMY

{
  my $app = App::git::ship->new;
  $app = $app->init('Perl/Ship.pm', 0);

  create_bad_main_module();
  eval { $app->ship };
  like $@, qr{Could not update VERSION in}, 'Could not update VERSION';

  create_main_module();
  $app->ship;

  is $upload_file, 'Perl-Ship-0.01.tar.gz', 'CPAN::Uploader uploaded file';
}

done_testing;

sub create_bad_main_module {
  open my $MAIN_MODULE, '>', File::Spec->catfile(qw( lib Perl Ship.pm )) or die $!;
  print $MAIN_MODULE "package Perl::Ship;\n=head1 NAME\n\nPerl::Ship\n\n1";
}

sub create_main_module {
  open my $MAIN_MODULE, '>', File::Spec->catfile(qw( lib Perl Ship.pm )) or die $!;
  print $MAIN_MODULE "package Perl::Ship;\n=head1 NAME\n\nPerl::Ship\n\n=head1 VERSION\n\n0.00\n\n=cut\n\nour \$VERSION = '42';\n\n1";
}