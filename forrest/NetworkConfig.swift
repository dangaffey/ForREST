//
//  NetworkConfig.swift
//  forrest
//
//  Created by Daniel Gaffey on 9/20/17.
//  Copyright © 2017 UnchartedRealms. All rights reserved.
//

import Foundation


protocol NetworkConfigProtocol
{
    var OAuthConfig
}

class NetworkConfig
{
    
    public static class Builder
    {
        private Context context;
        private OAuthConfigProvider configProvider;
        private OAuthStateProvider stateProvider;
        private LatencyTrackingProvider trackingProvider;
        private boolean sslOverride = false;
        
        public Builder setContext(Context context)
    {
        this.context = context.getApplicationContext();
        return this;
        }
        
        
        public Builder setOAuthConfigProvider(OAuthConfigProvider configProvider)
    {
        this.configProvider = configProvider;
        return this;
        }
        
        
        public Builder setOAuthStateProvider(OAuthStateProvider stateProvider)
    {
        this.stateProvider = stateProvider;
        return this;
        }
        
        
        public Builder setLatencyTrackerProvider(LatencyTrackingProvider trackingProvider)
    {
        this.trackingProvider = trackingProvider;
        return this;
        }
        
        
        public Builder setSSLOverride(boolean sslOverride)
    {
        this.sslOverride = sslOverride;
        return this;
        }
        
        
        public NetworkConfig build()
    {
        return new NetworkConfig(this);
        }
    }
}


