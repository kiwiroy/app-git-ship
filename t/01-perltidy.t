use strict;
use warnings;
use Test::More;

if (eval 'use Test::PerlTidy; 1') {
  run_tests(
    path       => '.',
    perltidyrc => '.perltidyrc',
    exclude    => ['Makefile.PL', 'blib/', qr{^t/.*\.(?:t|pm)$}, 'workdir/']
  );
}
else {
  plan skip_all => "Test::PerlTidy not installed";
}

done_testing;
