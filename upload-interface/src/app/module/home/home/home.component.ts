import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { LocalStorageTokenService } from '../../../core/service/local-storage-token/local-storage-token.service';

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrl: './home.component.scss',
})
export class HomeComponent implements OnInit {
  token!: string | null;
  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private localStorageTokenService: LocalStorageTokenService
  ) {
    this.route.queryParamMap.subscribe(queryParams => {
      this.token = queryParams.get('jwt');
    });
  }
  ngOnInit(): void {
    this.router.navigate(['/upload']);
  }
}
