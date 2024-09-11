import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root',
})
export class LocalStorageTokenService {
  localStorageName = 'dentalQuoteToken';
  getToken(): string | null {
    return localStorage.getItem(this.localStorageName);
  }
  setToken(token: string): void {
    localStorage.setItem(this.localStorageName, token);
  }
  removeToken(): void {
    localStorage.removeItem(this.localStorageName);
  }
}
