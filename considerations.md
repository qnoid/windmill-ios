# Processing StoreKit transactions

Since transactions are only processed while the app is on the foreground, it's possible that multiple transactions, relating to the same subscription are processed in a quick burst.

Consider the following scenario:

An auto-renewable subscription with a duration of 5 minutes expires at 2019-03-03 11:14:56.92.
A renewable purchase is succesful; the transaction occurs while the app is in the background at 2019-03-03 11:19:56.92.
A second renewable purchase is succesful; the transaction occurs while the app is running at 2019-03-03 11:24:56.92.

Both transactions, having been in the queue, are now sent for processing.
