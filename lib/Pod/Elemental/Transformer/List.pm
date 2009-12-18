package Pod::Elemental::Transformer::List;
use Moose;
with 'Pod::Elemental::Transformer';

use Pod::Elemental::Element::Pod5::Command;
use Pod::Elemental::Selectors -all;

use namespace::autoclean;

sub transform_node {
  my ($self, $node) = @_;

  for my $i (reverse(0 .. $#{ $node->children })) {
    my $para = $node->children->[ $i ];
    next unless $self->__is_xformable($para);
    my @replacements = $self->_expand_list_paras( $para->children );
    splice @{ $node->children }, $i, 1, @replacements;
  }
}

sub __is_xformable {
  my ($self, $para) = @_;

  return unless $para->isa('Pod::Elemental::Element::Pod5::Region')
         and $para->format_name eq 'list';

  confess("list regions must be pod (=begin :list)") unless $para->is_pod;
  
  return 1;
}

my %_TYPE = (
  '=' => 'def',
  '*' => 'bul',
  '0' => 'num',
);

sub _expand_list_paras {
  my ($self, $paras) = @_;
  
  my @replacements;

  my $type;
  my $i = 1;

  PARA: for my $para (@$paras) {
    unless ($para->isa('Pod::Elemental::Element::Pod5::Ordinary')) {
      push @replacements, $self->__is_xformable($para)
         ? $self->_expand_list_paras($para->children)
         : $para;

      next PARA;
    }

    my $pip = q{}; # paragraph in progress
    my @lines = split /\n/, $para->content;

    LINE: for my $line (@lines) {
      if (my ($prefix, $rest) = $line =~ m{^(=|\*|(?:[0-9]+\.))\s+(.+)$}) {
        if (length $pip) {
          push @replacements, Pod::Elemental::Element::Pod5::Ordinary->new({
            content => $pip,
          });
        }

        $prefix = '0' if $prefix =~ /^[0-9]/;
        my $line_type = $_TYPE{ $prefix };
        $type ||= $line_type;

        confess("mismatched list types; saw $line_type marker after $type")
          if $line_type ne $type;

        my $method = "__paras_for_$type\_marker";
        my ($marker, $leftover) = $self->$method($rest, $i++);
        push @replacements, $marker;
        if (defined $leftover and length $leftover) {
          push @replacements, Pod::Elemental::Element::Pod5::Ordinary->new({
            content => $leftover,
          });
        }
        $pip = q{};
      } else {
        $pip .= "$line\n";
      }
    }

    if (length $pip) {
      push @replacements, Pod::Elemental::Element::Pod5::Ordinary->new({
        content => $pip,
      });
    }
  }

  unshift @replacements, Pod::Elemental::Element::Pod5::Command->new({
    command => 'over',
    content => 4,
  });

  push @replacements, Pod::Elemental::Element::Pod5::Command->new({
    command => 'back',
    content => '',
  });

  return @replacements;
}

sub __paras_for_num_marker {
  my ($self, $rest, $i) = @_;

  return (
    Pod::Elemental::Element::Pod5::Command->new({
      command => 'item',
      content => $i,
    }),
    $rest, 
  );
}

sub __paras_for_def_marker {
  my ($self, $rest) = @_;

  return (
    Pod::Elemental::Element::Pod5::Command->new({
      command => 'item',
      content => $rest,
    }),
    '',
  );
}

sub __paras_for_bul_marker {
  my ($self, $rest) = @_;

  return (
    Pod::Elemental::Element::Pod5::Command->new({
      command => 'item',
      content => '*',
    }),
    $rest, 
  );
}

1;
