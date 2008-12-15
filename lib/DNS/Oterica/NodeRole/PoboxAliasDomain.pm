package DNS::Oterica::NodeRole::PoboxAliasDomain;
use Moose;
extends 'DNS::Oterica::NodeRole';

sub name { 'com.pobox.alias-domain' }

after add_node => sub {
  my ($self, $node) = @_;
  $node->add_to_role('com.rightbox.domain');
};

augment as_data_lines => sub {
  my ($self) = @_;
  my @lines;

  my %mx_nodes = $self->hub->node_role('com.pobox.mx')->mx_nodes;

  for my $node ($self->nodes) {
    for my $mx (keys %mx_nodes) {
      push @lines, $self->rec->mx({
        name => $node->fqdn,
        mx   => $mx,
        node => $mx_nodes{$mx},
      });
    }
  }

  for my $node ($self->nodes) {
    for my $www_node ($self->hub->node_role('com.pobox.www')->nodes) {
      for my $prefix ('', map{"$_."} qw(w ww www wwww)) {
        push @lines, $self->rec->a({
          name => $prefix . $node->fqdn,
          node => $www_node,
        });
      }
    }
  }

  return @lines;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;
