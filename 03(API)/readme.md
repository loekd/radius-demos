# Call the Radius RP API

- Forward traffic:
    Expose Radius dashboard (blocking call):
    - `kubectl port-forward services/dashboard 8088:80 -n radius-system`
    - `explorer http://localhost:8088`

- Deploy the Application from step 1.
- Use the calls in the .http file to call the Radius Resource Provider 
  - This uses a proxy that is built into the dashboard.