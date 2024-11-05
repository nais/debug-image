# Debug

Image used for debugging purposes.

To connect to a debug instance you run kubectl debug like this:
```sh
 kubectl debug -it <podName> --image="europe-north1-docker.pkg.dev/nais-io/nais/images/debug:latest" --profile=restricted
 ```

The debug container will exist in the pod until the pod restarts.
