# Define the simulation duration
set val(stop) 10.0 ; # time of simulation end

# Create a NS simulator instance
set ns [new Simulator]

# Open the NS trace file to log all events
set tracefile [open 3.tr w]
$ns trace-all $tracefile

# Open the NAM trace file for animation
set namfile [open 3.nam w]
$ns namtrace-all $namfile

# Create 7 nodes in the simulation
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]

# Create links between nodes with specific bandwidth, delay, and queue limit
$ns duplex-link $n0 $n1 1Mb 50ms DropTail
$ns queue-limit $n0 $n1 50
$ns duplex-link $n0 $n3 1Mb 50ms DropTail
$ns queue-limit $n0 $n3 50
$ns duplex-link $n0 $n4 1Mb 50ms DropTail
$ns queue-limit $n0 $n4 50
$ns duplex-link $n0 $n5 1Mb 50ms DropTail
$ns queue-limit $n0 $n5 2
$ns duplex-link $n0 $n2 1Mb 50ms DropTail
$ns queue-limit $n0 $n2 2
$ns duplex-link $n0 $n6 1Mb 50ms DropTail
$ns queue-limit $n0 $n6 1

# Define the positions of the nodes for visualization in NAM
$ns duplex-link-op $n0 $n1 orient right-up
$ns duplex-link-op $n0 $n2 orient right
$ns duplex-link-op $n0 $n3 orient right-down
$ns duplex-link-op $n0 $n4 orient left-down
$ns duplex-link-op $n0 $n5 orient left
$ns duplex-link-op $n0 $n6 orient left-up

# Define a custom procedure for the Ping agent to handle received packets
Agent/Ping instproc recv {from rtt} {
  $self instvar node_
  puts "node [$node_ id] received ping answer from $from with round-trip-time $rtt ms."
}

# Create Ping agents for nodes
set p1 [new Agent/Ping]
set p2 [new Agent/Ping]
set p3 [new Agent/Ping]
set p4 [new Agent/Ping]
set p5 [new Agent/Ping]
set p6 [new Agent/Ping]

# Attach Ping agents to respective nodes
$ns attach-agent $n1 $p1
$ns attach-agent $n2 $p2
$ns attach-agent $n3 $p3
$ns attach-agent $n4 $p4
$ns attach-agent $n5 $p5
$ns attach-agent $n6 $p6

# Connect Ping agents to simulate communication between nodes
$ns connect $p1 $p4
$ns connect $p2 $p5
$ns connect $p3 $p6

# Schedule Ping sends at specific times
$ns at 0.2 "$p1 send"
$ns at 0.4 "$p2 send"
$ns at 0.6 "$p3 send"
$ns at 1.0 "$p4 send"
$ns at 1.2 "$p5 send"
$ns at 1.4 "$p6 send"

# Define the finish procedure to end the simulation
proc finish {} {
  global ns tracefile namfile
  $ns flush-trace
  close $tracefile
  close $namfile
  exec nam 3.nam & # Open NAM animation
  exit 0
}

# Schedule the simulation end and final tasks
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"

# Start the simulation
$ns run

#############

# AWK script to count dropped packets from the trace file
BEGIN {
  Count = 0; # Initialize drop counter
}
{
  event = $1; # Extract the event type
  if (event == "d") { # Check if the event is a packet drop
    Count++;
  }
}
END {
  printf("Number of packets dropped: %d\n", Count); # Print total drops
}
