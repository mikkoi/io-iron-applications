package IO::Iron::Applications::IronCache::Command::get;

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

# ABSTRACT: Get item/items from cache/caches.

# VERSION: generated by DZP::OurPkgVersion

=head1 SYNOPSIS

This package is for internal use of IO::Iron::Applications.

=cut

use Data::Dumper;

use IO::Iron::Applications::IronCache -command;

sub description {
	return "Get item/items from cache/caches.";
}

sub usage_desc {
	my ($self, $opt, $args) = @_;
	return $opt->arg0() . " %o get item <item_key>[,<item_key>] --cache <cache_name>[,<cache_name>]";
}

sub opt_spec {
	return (
        IO::Iron::Applications::Command::CommandBase::opt_spec_base(),
		[ 'cache=s',	"cache name or names (separated with \',\')", ],
	);
}

sub validate_args {
	my ($self, $opt, $args) = @_;
    $self->validate_args_base($opt, $args);
	$self->usage_error("wrong number of arguments") unless scalar @{$args} == 2;
	$self->usage_error("invalid arguments") unless ($args->[0] eq 'item');
    $self->usage_error("missing cache name") unless (defined $opt->{'cache'});
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
    my %output;
    %output = IO::Iron::Applications::IronCache::Functionality::get_item(%parameters);

    print $self->combine_template("get_item", \%output);
    return 0;
}

1;
