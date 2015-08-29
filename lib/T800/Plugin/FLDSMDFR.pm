package T800::Plugin::FLDSMDFR;

use Moose;
use Template;
use List::Util qw(shuffle);

with 'T800::Role::Plugin';
with 'T800::Role::PluginCommands';
with 'T800::Role::IRCHandler';
with 'T800::Role::Initialization';
with 'T800::Role::SpecialMessages';

with 'Universa::Role::Configuration' => {
    configfile => 'fldsmdfr.json',
    store      => 'phrases',
    class      => 'T800::Plugin::FLDSMDFR::Phrases',
};

has 'names_cache' => (
    isa           => 'HashRef[ArrayRef[Str]]|Undef',
    is            => 'ro',
    default       => sub { {} },
    );


sub BUILD {
    my $self = shift;

    $self->name('serve');
    $self->add_command(
	liquid => 'serve_liquid',
	solid  => 'serve_solid',
	);
}

sub on_353 {
    my ($self, $channel, $names) = @_;

    $self->names_cache->{$channel} = $names;
}

sub serve_liquid { shift->serve('liquid', @_) }
sub serve_solid  { shift->serve('solid',  @_) }

sub serve {
    my ($self, $type, $who, $where, $what) = @_;
    my ($channel, $nick) = ($where->[0], (split '!', $who)[0]);

    my @phrases = @{ $self->phrases->$type };
    my $phrase = $phrases[ rand @phrases];

    # Channel list
    my @names = shuffle @{ $self->names_cache->{$channel}};

    my $vars  = {
	nick       => $nick,
	channel    => $channel,
	names      => \@names,
	item       => $what,
	randomnick => sub { my @list = shuffle @names; $list[rand @names] },
    };

    use Data::Dumper;
    print Dumper $vars;

    my $result = '';
    my $tt  = Template->new;
    $tt->process(\$phrase, $vars, \$result) || return warn $tt->error;

    $self->irc->yield( privmsg => $channel => "The FLDSMDFR rumbles in the sky - $result" );
}

__PACKAGE__->meta->make_immutable;

package T800::Plugin::FLDSMDFR::Phrases;

use Moose;

with 'MooseX::SimpleConfig';


has 'liquid' => ( isa => 'ArrayRef[Str]', is => 'ro', default => sub { [] });
has 'solid'  => ( isa => 'ArrayRef[Str]', is => 'ro', default => sub { [] });

__PACKAGE__->meta->make_immutable;

__DATA__
{
  "liquid": [
    "The ground begins to rumble and shake, before [% randomnick %] and [% randomnick %] find themselves sprinting for their lives as massive quantities of [% item %] bleeds through thousands of windows from the buildings around them, clashing into the roads and flooding everything.",
    "[% names.0 %], [% randomnick %], and [% randomnick %] all look a bit green around the gills before walking toward all of you like zombies and begin erupting barrelfulls of [% item %] from their eyes, noses, ears, and mouths like an olympic ipecac guzzling contest, drenching [% randomnick %] including themselves in the process."
  ],
  "solid": [
    "[% item %]s spiral down from the sky, haphazardly piling in the streets. Amongst all the screaming, a [% item %] happens to smack [% randomnick %] right in the face, knocking them down.",
    "As [% randomnick %] happily prances accross campus in a tutu, they look up and find dark clouds circling over as a large abundance of enormous [% item %]s blast their car into bits."
  ]
}
