package Pod::Elemental::Transformer::List;
use Moose;
with 'Pod::Elemental::Transformer';

use Pod::Elemental::Element::Pod5::Command;

sub transform_node {
  my ($self, $node) = @_;

  for my $i (reverse(0 .. $#{ $node->children })) {
    my $para = $node->children->[ $i ];
    next unless $para->isa('Pod::Elemental::Element::Pod5::Region');

    my @replacements = $self->_expand_list_paras( $para->children );
    splice @{ $node->children }, $i, 1, @replacements;
  }
}

sub _expand_list_paras {
  my ($self, $paras) = @_;

  return(
    Pod::Elemental::Element::Pod5::Command->new({
      command => 'over',
      content => 4,
    }),

    Pod::Elemental::Element::Pod5::Command->new({
      command => 'back',
      content => '',
    }),
  );   
}

1;
