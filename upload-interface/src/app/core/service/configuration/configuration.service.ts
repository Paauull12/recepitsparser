import { HttpClient, HttpBackend } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable, map, shareReplay } from 'rxjs';

import { Configuration } from '../../model/configuration.model';

@Injectable({ providedIn: 'root' })
export class ConfigurationService {
  private httpClient!: HttpClient;
  public readonly configUrl = `${window.location.origin}/config/config.json`;

  private sub$!: Observable<Configuration>;

  // To bypass interceptors used for external requests, we use HttpBackend to create a interceptor-less HttpClient
  // Taken from https://stackoverflow.com/a/49013534
  constructor(private handler: HttpBackend) {
    this.httpClient = new HttpClient(handler);
  }

  getConfiguration(): Observable<Configuration> {
    if (this.sub$) {
      return this.sub$;
    }
    this.sub$ = this.httpClient
      .get<Configuration>(this.configUrl)
      .pipe(
        map(config => {
          return config;
        })
      )
      .pipe(shareReplay(1));
    return this.sub$;
  }
}
