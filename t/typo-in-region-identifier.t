#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 4;
use Test::Fatal;

use Pod::Elemental;
use Pod::Elemental::Transformer::Pod5;
use Pod::Elemental::Transformer::List;

ok my $pod5 = Pod::Elemental::Transformer::Pod5->new, 'new pod5';
ok my $list = Pod::Elemental::Transformer::List->new, 'new list';

my $pod = <<'END_POD'; 
=for list
* Missing
* a
* colon
* before
* list
END_POD

ok my $doc = Pod::Elemental->read_string( $pod ), 'read_string';

like(
  exception { $pod5->transform_node( $doc ); $list->transform_node( $doc ); },
  qr/list regions must be pod/,
  'list regions must be pod'
);
