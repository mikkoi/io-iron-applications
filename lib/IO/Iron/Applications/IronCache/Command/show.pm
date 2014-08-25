package IO::Iron::Applications::IronCache::Command::show;

## no critic (Documentation::RequirePodAtEnd)
## no critic (Documentation::RequirePodSections)
## no critic (RegularExpressions::RequireExtendedFormatting)
## no critic (RegularExpressions::RequireLineBoundaryMatching)
## no critic (RegularExpressions::ProhibitEscapedMetacharacters)

use 5.010_000;
use strict;
use warnings FATAL => 'all';

# Global creator
BEGIN {
    use parent qw( IO::Iron::Applications::Command::CommandBase ); # Inheritance
}

# Global destructor
END {
}

# ABSTRACT: Show the parameters of a single cache.

# VERSION: generated by DZP::OurPkgVersion

=head1 SYNOPSIS

This package is for internal use of IO::Iron packages.

=cut

use Data::Dumper;

use IO::Iron::Applications::IronCache -command;

use Log::Any  qw{$log};
use Carp::Assert;
use Carp::Assert::More;
use Carp;
use English '-no_match_vars';
use Try::Tiny;
use Scalar::Util qw{blessed looks_like_number};
use Exception::Class (
      'IronHTTPCallException' => {
        fields => ['status_code', 'response_message'],
      }
  );

require IO::Iron::IronCache::Client;

sub description {
	return "Show information about cache(s).";
}

sub usage_desc { 
	my ($self, $opt, $args) = @_;
	return $opt->arg0() . " %o show cache cache_name[,cache_name][,name_with_wildcards]";
}

sub opt_spec {
	return (
        IO::Iron::Applications::Command::CommandBase::opt_spec_base(),
	);
}

sub validate_args {
	my ($self, $opt, $args) = @_;
    $self->validate_args_base($opt, $args);
	$self->usage_error("wrong number of arguments") unless scalar @{$args} == 2;
	$self->usage_error("invalid arguments") unless ($args->[0] eq 'cache');
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
    $parameters{'cache_name'} = $args->[1] if ($args->[0] eq 'cache' && scalar @{$args} > 1);
    my %output;
    %output = IO::Iron::Applications::IronCache::Functionality::show_cache(%parameters);

    print $self->combine_template("show_cache", \%output);
    return 0;
}

1;
