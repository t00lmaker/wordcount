terraform {
    backend "s3" {
        bucket = "lab2-tfstate"
        key    = "state.tfstate"
    }
}
