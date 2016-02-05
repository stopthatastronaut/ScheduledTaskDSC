ipmo pester


Describe "Top level repo tests" {

}

Describe "Module tests" {
    Context "With Module dot-loaded" {
        Mock New-ScheduledTask { return "<xml>Some XML Here</xml>"}

    }

    Context "Running module in DSC" {

    }

}

Describe "Testing the tests" {
    # picks up the example scripts and makes sure they throw nothing
}