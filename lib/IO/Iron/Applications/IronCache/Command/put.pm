package IO::Iron::Applications::IronCache::Command::put;

use 5.010_000;
use strict;
use warnings FATAL => 'all';

# Global creator
BEGIN {
    # Inheritance
    use parent qw( IO::Iron::Applications::Command::CommandBase );
}

# Global destructor
END {
}

# ABSTRACT: Put or replace item/items to a cache/caches.

# VERSION: generated by DZP::OurPkgVersion

=head1 SYNOPSIS

This package is for internal use of IO::Iron::Applications.

=cut

use Data::Dumper;

use IO::Iron::Applications::IronCache -command;

sub description {
	return "Put or replace item/items to a cache/caches.";
}

sub usage_desc {
	my ($self, $opt, $args) = @_;
	return $opt->arg0() . " %o put item <item_key>[,<item_key>] --cache <cache_name>[,<cache_name>]";
}

sub opt_spec {
    # Note, dashes '-' become underscores '_' during opt_spec conversion!
	return (
        IO::Iron::Applications::Command::CommandBase::opt_spec_base(),
		[ 'cache=s',	"cache name or names (separated with \',\')", ],
        [ 'expires-in=i', 'How long in seconds to keep the item in the cache before it is deleted', ],
        [ 'replace!', 'Only set the item if the item is already in the cache', ],
        [ 'add!', 'Only set the item if the item is not already in the cache', ],
        [ 'value=s', 'Item value, any string', ],
        [ 'create-cache', 'If cache does not exist, create it', { 'default' => 0, }, ],
	);
}

sub validate_args {
	my ($self, $opt, $args) = @_;
    $self->validate_args_base($opt, $args);
	$self->usage_error("wrong number of arguments") unless scalar @{$args} == 2;
	$self->usage_error("invalid arguments") unless ($args->[0] eq 'item');
    $self->usage_error("missing cache name") unless (defined $opt->{'cache'});
    $self->usage_error("cannot use both \'replace\' and \'add\' together") if (defined $opt->{'replace'} && defined $opt->{'add'});
}

sub execute {
    my ($self, $opts, $args) = @_;

    $self->raise_logging_levels_from_options($opts);
    if($self->check_for_iron_io_config($opts)) {
        return 1;
    }
    my %parameters;
    $parameters{'config'} = $opts->{'config'} if defined $opts->{'config'};
    $parameters{'policies'} = $opts->{'policies'} if defined $opts->{'policies'};
    $parameters{'no-policy'} = $opts->{'no-policy'};
    $parameters{'item_key'} = [ split q{,}, $args->[1] ]; # expects array
    $parameters{'cache_name'} = [ split q{,}, $opts->{'cache'} ]; # expects array
    $parameters{'item_value'} = ''; # Replace below.
    $parameters{'create_cache'} = $opts->{'create_cache'};
    $parameters{'expires_in'} = $opts->{'expires_in'} if defined $opts->{'expires_in'};
    # TODO Missing parameters replace/add.
    if(defined $opts->{'value'}) {
        $parameters{'item_value'} = $opts->{'value'}
    }
    else {
        while(<STDIN>) {
            chomp;
            $parameters{'item_value'} .= $_;
        }
    }
    my %output;
    %output = IO::Iron::Applications::IronCache::Functionality::put_item(%parameters);

    print $self->combine_template("put_item", \%output);
    return 0;
}

1;
