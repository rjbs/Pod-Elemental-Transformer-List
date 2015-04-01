#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 3;
use Test::Differences;

use Pod::Elemental;
use Pod::Elemental::Transformer::List;

ok my $transformer = Pod::Elemental::Transformer::List->new, 'new';

my $pod = <<'END_POD'; 
=for :not_a_list
* foo
* bar
* baz
END_POD

ok my $doc = Pod::Elemental->read_string( $pod ), 'read_string';

$transformer->transform_node( $doc );

eq_or_diff($doc->as_pod_string, "=pod\n\n$pod=cut\n", 'pod string');

=pod

tried the following in equiv-pods.t, but it failed:

list_is not_a_list => <<'END_POD';
=for :not_a_list
* foo
* bar
* baz
--------------------------------------
=for :not_a_list
* foo
* bar
* baz
END_POD

t/equiv-pods.t ........................ 1/? 
#   Failed test 'not_a_list'
#   #   at t/equiv-pods.t line 31.
#   # +---+------------------------+---+------------------+
#   # | Ln|Got                     | Ln|Expected          |
#   # +---+------------------------+---+------------------+
#   # |  1|'=pod                   |  1|'=pod             |
#   # |  2|                        |  2|                  |
#   # *  3|=for :not_a_list * foo  *  3|=for :not_a_list  *
#   # |   |                        *  4|* foo             *
#   # |  4|* bar                   |  5|* bar             |
#   # |  5|* baz                   |  6|* baz             |
#   # |  6|                        |  7|                  |
#   # |  7|=cut                    |  8|=cut              |
#   # |  8|'                       |  9|'                 |
#   # +---+------------------------+---+------------------+
#   # Looks like you failed 1 test of 13.
=cut
