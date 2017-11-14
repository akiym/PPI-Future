requires 'Clone'           => '0.30';
requires 'File::Spec'      => '3.2701';
requires 'IO::String'      => '1.07';
requires 'List::Util'      => '1.33';
requires 'Params::Util'    => '1.00';

# Modules needed for PPI::Cache
requires 'Digest::MD5' => '2.35';
requires 'Storable'    => '2.17';

# Test-time dependencies (bundle as many as we can)
on test => sub {
    requires 'Class::Inspector' => '1.22';
    requires 'File::Remove'     => '1.42';
    requires 'Test::More'       => '0.86';
    requires 'Test::Object'     => '0.07';
    requires 'Test::SubCalls'   => '1.07';
    requires 'Test::Deep';
};
