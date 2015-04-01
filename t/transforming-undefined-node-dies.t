#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 2;
use Test::Fatal;

use Pod::Elemental::Transformer::List;

ok my $transformer = Pod::Elemental::Transformer::List->new;

like(
  exception { my $node = $transformer->transform_node( undef ); },
  qr/undefined/,
  'undefined node'
);
