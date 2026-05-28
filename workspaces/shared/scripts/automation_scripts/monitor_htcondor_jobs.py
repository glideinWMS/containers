import htcondor
import os
import argparse

def monitor_event_log(event_log_path, username):
    event_log = htcondor.JobEventLog(event_log_path)
    print(f"Monitoring HTCondor event log: {event_log_path} for user: {username}")

    for event in event_log.events(0):  
        if hasattr(event, "submitter") and event.submitter != username:
            continue

        if isinstance(event, htcondor.JobEventLog.JobExecutedEvent):
            print(f"Job Started by {username}: Cluster {event.cluster} Job {event.proc}")
        elif isinstance(event, htcondor.JobEventLog.JobTerminatedEvent):
            print(f"Job Completed by {username}: Cluster {event.cluster} Job {event.proc}")
        else:
            print(f"Unhandled Event for {username}: {event}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Monitor HTCondor job events for a specific user.")
    parser.add_argument(
        "username", 
        type=str, 
        help="The username of the submitter whose jobs you want to monitor."
    )
    parser.add_argument(
        "--log-path", 
        type=str, 
        default="/var/lib/condor/JobEventLog",
        help="Path to the HTCondor job event log file (default: /var/lib/condor/JobEventLog)."
    )
    args = parser.parse_args()

    if not os.path.exists(args.log_path):
        print(f"Event log not found at {args.log_path}")
    else:
        monitor_event_log(args.log_path, args.username)

