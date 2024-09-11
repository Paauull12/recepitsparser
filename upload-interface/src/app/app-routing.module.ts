import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { UnauthorizedComponent } from './shared/module/unauthorized/unauthorized.component';
import { DentalQuoteComponent } from './module/dental-quote/dental-quote.component';
import { HomeComponent } from './module/home/home/home.component';

const routes: Routes = [
  { path: '', component: HomeComponent },
  {
    path: 'upload',
    component: DentalQuoteComponent
  },
  {
    path: 'unauthorized',
    component: UnauthorizedComponent,
  },
  {
    path: '**',
    redirectTo: '/upload',
  },
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule],
})
export class AppRoutingModule {}
