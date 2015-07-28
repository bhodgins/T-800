package T800::Plugin::CardsWithInhumanity;

use Moose;
use JSON::Tiny qw(decode_json);

with 'T800::Role::Plugin';
with 'T800::Role::PluginCommands';
with 'T800::Role::IRCHandler';
with 'T800::Role::Initialization';

with 'Universa::Role::Configuration' => {
    configfile => 'inhumanity.yml',
    class      => 'T800::Plugin::CardsWithInhumanity::Config',
};

has 'cards' => (
    isa     => 'ArrayRef[HashRef[Any]]|Undef',
    is      => 'rw',
    lazy    => 1,
    builder => '_load_cards',
    );


sub t800_init {
    my $self = shift;

    $self->name('inhumanity');
    $self->add_command(
	'start'  => 'start_game',
	'stop'   => 'stop_game',
	'score'  => 'show_score',
	'skip'   => 'skip_turn',    # Requires vote. Useful for AFK people.
	'reload' => 'reload_cards', # reads cards.json from disk
	'join'   => 'join_game',
	);
}

sub _load_cards {
    my $self = shift;

    open my $fh, '<', $self->config->cards_path
	or return warn $!;

    my $cards = {};
    {
	local $/ = undef;
	$cards = decode_json(<$fh>);
	close $fh;
    }

    $cards;
}

sub start_game {
    my ($self, $who, $what, $where) = @_;
    my ($nick, $channel) = ((split '!', $who)[0], $where->[0]);

    # TODO:
    # - add $nick to players list
    # - Check for existing game

    $self->irc->yield(
	'privmsg',
	$channel,
	"$nick would like to start a new game of inhumanity. If you would like to play, type !join now.");
	);
}

sub stop_game {

}

sub show_score {

}

sub skip_turn {

}

sub join_game {

}

sub reload_cards { $_[0]->cards( $_[0]->_load_cards ) }

__PACKAGE__->meta->make_immutable;

package T800::Plugin::CardsWithInhumanity::Session;

use Moose;


has 'white_deck'   => (
    isa            => 'ArrayRef[HashRef[Any]]|Undef',
    is             => 'rw',
    builder        => '_build_white_deck',
    lazy           => 1,
    );

has 'black_deck'   => (
    isa            => 'ArrayRef[HashRef[Any]]|Undef',
    is             => 'rw',
    builder        => '_build_black_deck',
    lazy           => 1,
);

has 'discard_deck' => (
    isa            => 'ArrayRef[HashRef[Any]]|Undef',
    is             => 'rw',
    default        => sub { {} },
    lazy           => 1,
    );

has 'plugin'       => (
    isa            => 'CardsWithInhumanity',
    is             => 'ro',
    required       => 1,
    );

has 'players'      => (
    isa            => 'ArrayRef[T800::Plugin::CardsWithInhumanity::Player]',
    is             => 'ro',
    default        => sub { [] },
    );

has 'channel'      => (
    isa            => 'Str',
    is             => 'ro',
    required       => 1,
    );


sub _build_black_deck { shift->white_deck(_populate_deck('Q')) }
sub _build_white_deck { shift->black_deck(_populate_deck('A')) }

sub _populate_deck {
    my ($self, $type) = @_;

    grep { $_->{'cardType'} eq $type } @{ $self->plugin->cards }
}

__PACKAGE__->meta->make_immutable;

package T800::Plugin::CardsWithInhumanity::Player;

use Moose;

has 'hand'         => (
    isa            => 'ArrayRef[HashRef[Any]]|Undef',
    is             => 'rw',
    default        => sub { [] },
    );

# Answer cards the player has won:
has 'store'        => (
    isa            => 'ArrayRef[HashRef[Any]]|Undef',
    default        => sub { [] },
    );

__PACKAGE__->meta->make_immutable;

package T800::Plugin::CardsWithInhumanity::Config;

use Moose;

with 'MooseX::SimpleConfig';

has 'cards_path' => ( isa => 'Str', is => 'ro', default => '');


__PACKAGE__->meta->make_immutable;

__DATA__
---
# Configuration for Cards against inhumanity:
#
# We recommend making a directory named vendor and cloning the following git
# repository from there:
# https://github.com/nodanaonlyzuul/against-humanity
#
# The path to the json file:
cards_path: "vendor/against-humanity/source/cards.json"
...
